import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// This manages the List of Coffee Maps
/*
The coffeeProvider manages the Product Catalog (fetching from Unsplash), 
while the cartProvider manages User Selection.

*/
final List<Map<String, dynamic>> initialCoffeeList = [];

class CoffeeNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  CoffeeNotifier() : super(initialCoffeeList);

  bool _isLoading = false;
  int _currentPage = 1;
  String _lastQuery = "";
  bool get isLoading => _isLoading;
  // New: Centralized search logic
  Future<void> fetchCoffeeImages(
    String query, {

    bool isNewSearch = false,
  }) async {
    if (_isLoading) return;
    final effectiveQuery = query.trim().isEmpty ? "Coffee Shop" : query;
    try {
      _isLoading = true;

      if (isNewSearch) {
        _currentPage = 1;
        _lastQuery = effectiveQuery;
      }

      // Use the internal trackers for the API call
      final images = await getCoffeeImageBatch(effectiveQuery, _currentPage);

      final newItems = images
          .map(
            (img) => {
              'id': img['id'],
              'name': _lastQuery.isEmpty ? "Coffee" : _lastQuery,
              'image': img['url'],
              'status': 'available',
              'isFavorite': false,
            },
          )
          .toList();

      if (isNewSearch) {
        state = newItems..shuffle();
      } else {
        state = [...state, ...newItems]..shuffle();
      }

      _currentPage++; // Increment for the next "load more" trigger
    } catch (e) {
      debugPrint("Error fetching images in Provider: $e");
    } finally {
      _isLoading = false;
      // We force a tiny state update if needed to notify listeners of loading change
      state = [...state];
    }
  }

  // Firebase Firestore Instance
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> toggleFirebaseFav(Map<String, dynamic> item) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(item['id']);

    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.delete();
    } else {
      await docRef.set({
        'id': item['id'],
        'name': item['name'],
        'image': item['image'],
        'price': item['price'],
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ADD TO FIREBASE CART
  Future<void> addToFirebaseCart(Map<String, dynamic> item) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(item['id']);

    final doc = await docRef.get();

    if (doc.exists) {
      // If it's already there, just bump the number
      await docRef.update({'quantity': FieldValue.increment(1)});
    } else {
      // New item entry
      await docRef.set({
        'id': item['id'],
        'name': item['name'],
        'image': item['image'],
        'price': item['price'],
        'quantity': 1,
      });
    }
  }

  // Initialize with the data from your API
  void setFeed(List<Map<String, dynamic>> newFeed) {
    state = newFeed;
  }

  // Add more items (Pagination)
  void addItems(List<Map<String, dynamic>> moreItems) {
    state = [...state, ...moreItems];
  }

  // Toggle favorite logic happens here now!
  void toggleFavorite(Map<String, dynamic> targetItem) {
    state = [
      for (final item in state)
        if (item['image'] == targetItem['image']) // Match by unique image URL
          {...item, 'isFavorite': !(item['isFavorite'] ?? false)}
        else
          item,
    ];
  }
}

// This is the global "hook" we use in our screens
final coffeeProvider =
    StateNotifierProvider<CoffeeNotifier, List<Map<String, dynamic>>>((ref) {
      return CoffeeNotifier();
    });

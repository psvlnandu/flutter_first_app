import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// This manages the List of Coffee Maps
/*
The coffeeProvider manages the Product Catalog (fetching from Unsplash), 
while the cartProvider manages User Selection.
KEY MATCHING-
Field,Unsplash Key,Your Firebase Key
Name,alt_description,name
Image,urls['small'],image
ID,id,id
*/
final List<Map<String, dynamic>> initialCoffeeList = [];

class CoffeeNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  CoffeeNotifier() : super(initialCoffeeList);

  int _currentPage = 1;
  bool isLoading = false;
  String lastQuery = "";
  // Unified loading function to handle both feed and search
  Future<void> searchCoffee(String query, {bool isNewSearch = false}) async {
    if(isLoading)return;
    isLoading = true;
    if (isNewSearch) {
      _currentPage = 1;
      // Save the query so we know what to 'load more' of later
      lastQuery = query.isEmpty ? "Coffee" : query;
    }
    // // Use a default search if the query is empty
    // final searchTerm = query.isEmpty ? "Coffee" : query;

    // List<Map<String, dynamic>> newItems = [];
    // If query is empty, use your default menu, otherwise search specifically for that term
    // final itemsToFetch = _currentSearchQuery.isEmpty
    //     ? _coffeeMenu
    //     : [
    //         {'name': _currentSearchQuery, 'status': 'available'},
    //       ];

    try {
      // Calling your existing Unsplash helper
      List<Map<String, String>> images = await getCoffeeImageBatch(
        lastQuery,
        _currentPage,
      );

      final newItems = images
          .map(
            (img) => {
              'id': img['id'],
              'name': lastQuery,
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
      _currentPage++;
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      isLoading = false;
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
        // FIX: Check all possible name keys so Firebase never gets a Null
        'name': item['name'] ?? item['alt_description'] ?? 'Delicious Coffee',
        // FIX: Check all possible image keys
        'image': item['image'] ?? item['imageUrl'] ?? item['urls']?['small'] ?? '',
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

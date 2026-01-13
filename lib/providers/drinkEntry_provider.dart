import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

final drinkEntryProvider =
    StateNotifierProvider<DrinkEntryNotifier, AsyncValue<void>>((ref) {
      return DrinkEntryNotifier();
    });

class DrinkEntryNotifier extends StateNotifier<AsyncValue<void>> {
  DrinkEntryNotifier() : super(const AsyncValue.data(null));

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveEntry(DrinkEntry entry) async {
    final user = _auth.currentUser;
    if (user == null) {
      state = AsyncValue.error("User not logged in", StackTrace.current);
      return;
    }
    state = const AsyncValue.loading();
    try {
      // 1. Upload Image to Firebase Storage
      String downloadUrl = "";

      if (entry.imagePath.isNotEmpty) {
        final storageRef = _storage.ref().child(
          'users/${user.uid}/drinks/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        if (kIsWeb) {
          // FIX: Use 'http' to get bytes from the blob URL instead of 'File'
          final response = await http.get(Uri.parse(entry.imagePath));
          await storageRef.putData(response.bodyBytes);
        } else {
          // Mobile can still use File
          await storageRef.putFile(File(entry.imagePath));
        }
        downloadUrl = await storageRef.getDownloadURL();
      }
      // 2. Save Metadata + Download URL to Firestore
      final docRef = _db
          .collection('users')
          .doc(user.uid)
          .collection('entries')
          .doc();

      await docRef.set({
        'id': docRef.id,
        'imageUrl': downloadUrl, // The permanent link
        'location': entry.location,
        'rating': entry.rating,
        'notes': entry.notes ?? "",
        'createdAt': FieldValue.serverTimestamp(),
      });
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

class DrinkEntry {
  final String? id;
  final String imagePath; // Local path or URL
  final String location;
  final double rating;
  final String? notes;
  final bool isFavorite;

  DrinkEntry({
    this.id,
    required this.imagePath,
    required this.location,
    required this.rating,
    this.notes,
    this.isFavorite = false,
  });
}

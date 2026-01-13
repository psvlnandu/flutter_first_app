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
    debugPrint('--- Starting Save Process ---');
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('Error: No User Logged In');
      state = AsyncValue.error("User not logged in", StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();

    try {
      // 1. Determine if we need to upload to Storage or use a direct URL
      String finalImageUrl = "";
      bool isLocalFile = !entry.imagePath.startsWith('http');

      if (isLocalFile && entry.imagePath.isNotEmpty) {
        // HANDLE LOCAL UPLOAD (Mobile File or Web Blob)
        debugPrint('Step 1: Uploading local file to Storage...');
        final storageRef = _storage.ref().child(
          'users/${user.uid}/drinks/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        if (kIsWeb) {
          try {
            final response = await http.get(Uri.parse(entry.imagePath));
            if (response.statusCode == 200) {
              await storageRef.putData(response.bodyBytes);
            } else {
              throw Exception("Failed to fetch blob: ${response.statusCode}");
            }
          } catch (e) {
            debugPrint("Blob Fetch Error: $e");
            // If http fails, it might be a CORS/Security issue with the blob
            rethrow;
          }
        } else {
          await storageRef.putFile(File(entry.imagePath));
        }
        finalImageUrl = await storageRef.getDownloadURL();
      } else {
        // HANDLE UNPLASH / REMOTE URL
        // We don't upload to Storage; we just save the direct link
        finalImageUrl = entry.imagePath;debugPrint('Step 1: Using direct URL: $finalImageUrl');
      }
      debugPrint('Step 2: Writing to Firestore...');
      // 2. Save Metadata + finalImageUrl to Firestore
      final docRef = _db
          .collection('users')
          .doc(user.uid)
          .collection('entries')
          .doc();

      await docRef.set({
        'id': docRef.id,
        'imageUrl': finalImageUrl,
        'location': entry.location,
        'rating': entry.rating,
        'notes': entry.notes ?? "",
        'isFavorite': entry.isFavorite,
        'createdAt': FieldValue.serverTimestamp(),
      });

      state = const AsyncValue.data(null);
    } catch (e, st) {
      debugPrint('Error saving entry: $e');
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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
// This provider fetches favorites for the logged-in user in real-time
final userFavoritesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('favorites')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            // Include the ID so we know which one to delete later
            return {...doc.data(), 'id': doc.id};
          }).toList());
});
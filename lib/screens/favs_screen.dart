import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/coffee_provider.dart';
import 'package:flutter_application_1/providers/favs_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../widgets/coffee_card.dart'; // Import your reusable card

class FavsScreen extends ConsumerStatefulWidget {
  // ConsumerWidget is simple for static websies
  const FavsScreen({super.key});
  @override
  ConsumerState<FavsScreen> createState() => _FavsScreenState();
}

class _FavsScreenState extends ConsumerState<FavsScreen> {
  @override
  Widget build(BuildContext context) {
    final favsAsync = ref.watch(userFavoritesProvider);
    final user = FirebaseAuth.instance.currentUser;
    // Get the global list and filter for hearts
    final allCoffee = ref.watch(coffeeProvider);
    final favItems = allCoffee
        .where((item) => item['isFavorite'] == true)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Your Favourites')),
      body: favsAsync.when(
        data: (favItems) {
          if (favItems.isEmpty) {
            return const Center(child: Text('No favorites yet! ☕'));
          }
          return MasonryGridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            itemCount: favItems.length,
            itemBuilder: (context, index) {
              final item = favItems[index];
              return CoffeeCard(
                item: item,
                isFavorite: true,
                // Pass the Firestore logic here
                onToggleFavorite: () => _handleToggle(user?.uid, item),
                onAddToCart: () => {},
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Error loading favorites: $err')),
      ),
    );
  }

  // Logic to remove from Firestore
  void _handleToggle(String? uid, Map<String, dynamic> item) {
    if (uid == null) return;
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(item['id'])
        .delete();
  }
}

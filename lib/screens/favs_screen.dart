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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Favourites', style: TextStyle(fontFamily: 'Melodrame')),
      ),
      body: favsAsync.when(
        data: (favItems) {
          if (favItems.isEmpty) {
            return const Center(child: Text('No favorites yet!'));
          }

          return MasonryGridView.count(
            crossAxisCount: 2, // 4 might be too tiny on mobile; 2 matches your Diary/Feed
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            padding: const EdgeInsets.all(12),
            itemCount: favItems.length,
            itemBuilder: (context, index) { 
              final rawItem = favItems[index];
              final safeItem = {
                ...rawItem,
                'id': rawItem['id'] ?? 'unknown',
                'imageUrl': rawItem['imageUrl'] ?? rawItem['urls']?['small'] ?? '',
                'alt_description': rawItem['alt_description'] ?? rawItem['title'] ?? 'Specialty Coffee',
                'user': rawItem['user'] ?? {'name': 'Premium Roast'},
              };

              return CoffeeCard(
                item: safeItem,
                isFavorite: true,
                onToggleFavorite: () => ref.read(coffeeProvider.notifier).toggleFirebaseFav(safeItem),
                onAddToCart: () => ref.read(coffeeProvider.notifier).addToFirebaseCart(safeItem),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.brown)),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
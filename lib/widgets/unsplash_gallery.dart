import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_application_1/providers/coffee_provider.dart';
import 'package:flutter_application_1/providers/favs_provider.dart';
import 'package:flutter_application_1/widgets/coffee_card.dart';

class UnsplashGallery extends ConsumerWidget {
  final ScrollController? controller;
  final int crossAxisCount;
  final bool isDraggable; // NEW: So we can drag images in AddDrinkScreen

  const UnsplashGallery({
    super.key,
    this.controller,
    this.crossAxisCount = 2,
    this.isDraggable = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coffeeFeed = ref.watch(coffeeProvider);
    final favItems = ref.watch(userFavoritesProvider).value ?? [];

    return MasonryGridView.count(
      controller: controller,
      crossAxisCount: crossAxisCount,
      itemCount: coffeeFeed.length,
      itemBuilder: (context, index) {
        final rawItem = coffeeFeed[index];

        // 1. NORMALIZE the data so CoffeeCard doesn't get null values
        final normalizedItem = {
          ...rawItem,
          'id': rawItem['id'],
          'name': rawItem['alt_description'] ?? rawItem['name'] ?? 'Coffee Drink',
          // Map Unsplash 'urls/small' to the key your CoffeeCard expects
          'imageUrl': rawItem['urls']?['small'] ?? rawItem['image'] ?? rawItem['imageUrl'] ?? '',
        };
        final isFavorite = favItems.any(
          (fav) => fav['id'] == normalizedItem['id'],
        );

        // 2. Pass the normalized item to the card
        Widget card = CoffeeCard(
          item: normalizedItem,
          isFavorite: isFavorite,
          onToggleFavorite: () => ref
              .read(coffeeProvider.notifier)
              .toggleFirebaseFav(normalizedItem),
          onAddToCart: () => ref
              .read(coffeeProvider.notifier)
              .addToFirebaseCart(normalizedItem),
        );

        // If we are in the AddDrinkScreen, wrap the card so it can be dragged!
        if (isDraggable) {
          return Draggable<Map<String, dynamic>>(
            data: normalizedItem,
            feedback: SizedBox(
              width: 150,
              child: Opacity(opacity: 0.7, child: card),
            ),
            child: card,
          );
        }

        return card;
      },
    );
  }
}

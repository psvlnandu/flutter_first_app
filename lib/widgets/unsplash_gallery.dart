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
        final item = coffeeFeed[index];
        final isFavorite = favItems.any((fav) => fav['id'] == item['id']);

        Widget card = CoffeeCard(
          item: item,
          isFavorite: isFavorite,
          onToggleFavorite: () => ref.read(coffeeProvider.notifier).toggleFirebaseFav(item),
          onAddToCart: () => ref.read(coffeeProvider.notifier).addToFirebaseCart(item),
        );

        // If we are in the AddDrinkScreen, wrap the card so it can be dragged!
        if (isDraggable) {
          return Draggable<Map<String, dynamic>>(
            data: item,
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
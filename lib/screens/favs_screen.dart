import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/coffee_provider.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../widgets/coffee_card.dart'; // Import your reusable card

class FavsScreen extends ConsumerWidget { // ConsumerWidget is simple for static websies
  const FavsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the global list and filter for hearts
    final allCoffee = ref.watch(coffeeProvider);
    final favItems = allCoffee.where((item) => item['isFavorite'] == true).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Favourites')),
      body: favItems.isEmpty
          ? const Center(child: Text('No favorites yet! ☕'))
          : MasonryGridView.count(
              crossAxisCount: 4,
              itemCount: favItems.length,
              itemBuilder: (context, index) {
                final item = favItems[index];
                return CoffeeCard(
                  item: item,
                  onToggleFavorite: () => ref.read(coffeeProvider.notifier).toggleFavorite(item),
                  onAddToCart: () => {},
                );
              },
            ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../widgets/coffee_card.dart'; // Import your reusable card

class FavsScreen extends StatefulWidget {
  const FavsScreen({super.key});
  @override
  State<FavsScreen> createState() => _FavsScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // 1. Catch the full feed from HomeScreen arguments
    final List<Map<String, dynamic>> allItems = 
        ModalRoute.of(context)!.settings.arguments as List<Map<String, dynamic>>;

    // 2. Filter for only items that have a heart (isFavorite == true)
    final favItems = allItems.where((item) => item['isFavorite'] == true).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Favourites')),
      body: favItems.isEmpty
          ? const Center(child: Text('No favorites yet! ☕', style: TextStyle(fontSize: 18)))
          : MasonryGridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              padding: const EdgeInsets.all(10),
              itemCount: favItems.length,
              itemBuilder: (context, index) {
                final item = favItems[index];
                return CoffeeCard(
                  item: item,
                  onToggleFavorite: () {
                    setState(() {
                      // Toggle locally to update the UI heart immediately
                      item['isFavorite'] = !(item['isFavorite'] ?? false);
                    });
                  },
                  onAddToCart: () {
                    // Logic to add to cart can be added here later
                  },
                );
              },
            ),
    );
  }
}
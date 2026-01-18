import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/dashboard_provider.dart';
import 'package:flutter_application_1/widgets/coffee_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dashboardProvider);

    if (data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Coffee Journey', style: TextStyle(fontFamily: 'Melodrame')),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          _buildSlider(context, "Your Favourites", data['favorites']  as List<dynamic>, isFav: true),
          const SizedBox(height: 30),
          _buildSlider(context, "Most Ordered Drinks", data['mostOrdered'] as List<dynamic>),
          const SizedBox(height: 30),
          _buildLocationSlider(context, "Frequent Cafes", data['mostVisited'] as List<dynamic>),
        ],
      ),
    );
  }

  Widget _buildSlider(BuildContext context, String title, List items, {bool isFav = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(title, style: const TextStyle(fontFamily: 'Coolvetica', fontSize: 22)),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                child: CoffeeCard(
                  item: item,
                  isFavorite: isFav,
                  onToggleFavorite: () {}, // Handled in core logic
                  onAddToCart: () {},
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSlider(BuildContext context, String title, List items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(title, style: const TextStyle(fontFamily: 'Coolvetica', fontSize: 22)),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (context, index) {
              final locationEntry = items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.coffee, color: Colors.brown),
                      Text(locationEntry.key.split(',')[0], // Shows just the cafe name
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("${locationEntry.value} visits", style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
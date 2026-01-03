import 'package:flutter_riverpod/flutter_riverpod.dart';

// This manages the List of Coffee Maps
class CoffeeNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  CoffeeNotifier() : super([]);

  // Initialize with the data from your API
  void setFeed(List<Map<String, dynamic>> newFeed) {
    state = newFeed;
  }

  // Add more items (Pagination)
  void addItems(List<Map<String, dynamic>> moreItems) {
    state = [...state, ...moreItems];
  }

  // Toggle favorite logic happens here now!
  void toggleFavorite(Map<String, dynamic> targetItem) {
    state = [
      for (final item in state)
        if (item['image'] == targetItem['image']) // Match by unique image URL
          {...item, 'isFavorite': !(item['isFavorite'] ?? false)}
        else
          item,
    ];
  }
}

// This is the global "hook" we use in our screens
final coffeeProvider = StateNotifierProvider<CoffeeNotifier, List<Map<String, dynamic>>>((ref) {
  return CoffeeNotifier();
});
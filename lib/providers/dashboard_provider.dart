import 'package:flutter_application_1/providers/drinkEntry_provider.dart';
import 'package:flutter_application_1/providers/favs_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardProvider = Provider((ref) {
  final entriesAsync = ref.watch(userEntriesStreamProvider);
  final favsAsync = ref.watch(userFavoritesProvider);

  return entriesAsync.when(
    data: (entries) {
      // 1. Calculate Most Ordered Drinks
      final drinkCounts = <String, Map<String, dynamic>>{};
      for (var entry in entries) {
        final name = entry['name'] ?? 'Unknown';
        if (!drinkCounts.containsKey(name)) {
          drinkCounts[name] = {...entry, 'count': 0};
        }
        drinkCounts[name]!['count'] += 1;
      }
      final mostOrdered = drinkCounts.values.toList()
        ..sort((a, b) => b['count'].compareTo(a['count']));

      // 2. Calculate Most Visited Cafes
      final locationCounts = <String, int>{};
      for (var entry in entries) {
        final loc = entry['location'] ?? 'Unknown';
        locationCounts[loc] = (locationCounts[loc] ?? 0) + 1;
      }
      final mostVisited = locationCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return {
        'favorites': favsAsync.value ?? [],
        'mostOrdered': mostOrdered.take(5).toList(),
        'mostVisited': mostVisited.take(5).toList(),
      };
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
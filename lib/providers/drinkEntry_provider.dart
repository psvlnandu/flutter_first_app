import 'package:flutter_riverpod/flutter_riverpod.dart';

final drinkEntryProvider =
    StateNotifierProvider<DrinkEntryNotifier, AsyncValue<void>>((ref) {
      return DrinkEntryNotifier();
    });

class DrinkEntryNotifier extends StateNotifier<AsyncValue<void>> {
  DrinkEntryNotifier() : super(const AsyncValue.data(null));

  Future<void> saveEntry(DrinkEntry entry) async {
    state = const AsyncValue.loading();
    try {
      // Simulate API/DB call
      await Future.delayed(const Duration(seconds: 2));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

class DrinkEntry {
  final String? id;
  final String imagePath; // Local path or URL
  final String location;
  final double rating;
  final String? notes;
  final bool isFavorite;

  DrinkEntry({
    this.id,
    required this.imagePath,
    required this.location,
    required this.rating,
    this.notes,
    this.isFavorite = false,
  });
}

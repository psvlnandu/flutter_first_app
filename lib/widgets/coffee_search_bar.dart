import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/providers/coffee_provider.dart';

class CoffeeSearchBar extends ConsumerWidget {
  final String hintText;

  const CoffeeSearchBar({super.key, this.hintText = 'Search aesthetic vibes...'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.auto_awesome),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onSubmitted: (value) => ref
                  .read(coffeeProvider.notifier)
                  .searchCoffee(value, isNewSearch: true),
      ),
    );
  }
}
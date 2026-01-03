import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';
import 'package:flutter_application_1/providers/coffee_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    /*
    SOL01- 
    Use ModalRoute to "catch" the arguments passed from the previous screen
    
    The primary function of a ModalRoute is to ensure that 
    when a new route is displayed, the user can only interact with that new route
     (e.g., a dialog, a new full-screen page, a bottom sheet) until it is dismissed.

    SOL02-
    Instead of catching now, we are using Provider hence the "ref"
    */

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return ListTile(
            title: Text(cartItems[index]['name']),
            trailing: Row(
              // Use a Row to put two buttons side-by-side
              children: [
                // 1. Move to favs button
                IconButton(
                  icon: Icon(
                    (item['isFavorite'] ?? false)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: (item['isFavorite'] ?? false)
                        ? Colors.red
                        : Colors.grey,
                  ),
                  onPressed: () {
                    // This updates the global coffeeProvider
                    ref.read(coffeeProvider.notifier).toggleFavorite(item);

                    // Optional: Show a snackbar for feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Updated Favorites!')),
                    );
                  },
                ),
                // 2. Remove from cart button
                IconButton(
                  icon: const Icon(Icons.delete_outline_outlined),
                  onPressed: () =>
                      ref.read(cartProvider.notifier).removeFromCart(index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

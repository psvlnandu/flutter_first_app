import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        itemBuilder: (context, index) => ListTile(
          title: Text(cartItems[index]['name']),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () =>
                ref.read(cartProvider.notifier).removeFromCart(index),
          ),
        ),
      ),
    );
  }
}

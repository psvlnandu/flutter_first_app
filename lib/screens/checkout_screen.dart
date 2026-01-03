import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    // Use ModalRoute to "catch" the arguments passed from the previous screen
    /*
    The primary function of a ModalRoute is to ensure that 
    when a new route is displayed, the user can only interact with that new route
     (e.g., a dialog, a new full-screen page, a bottom sheet) until it is dismissed.
    */

    final List<Map<String, dynamic>> cartItems =
        ModalRoute.of(context)!.settings.arguments
            as List<Map<String, dynamic>>;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: cartItems.isEmpty
          ? const Center(child: Text("Your cart is empty!"))
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(cartItems[index]['name']),
                  trailing: Text('\$4.50'), // Example price
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';
import 'package:flutter_application_1/providers/coffee_provider.dart';
import 'package:flutter_application_1/widgets/checkout/billing_info_form.dart';
import 'package:flutter_application_1/widgets/checkout/personal_info_form.dart';
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
    // Define all your controllers here once
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _shipCity = TextEditingController();
    final _shipZip = TextEditingController();
    final _cardController = TextEditingController();
    /*
    SOL01- 
    Use ModalRoute to "catch" the arguments passed from the previous screen
    
    The primary function of a ModalRoute is to ensure that 
    when a new route is displayed, the user can only interact with that new route
     (e.g., a dialog, a new full-screen page, a bottom sheet) until it is dismissed.

    SOL02-
    Instead of catching now, we are using Provider hence the "ref"

    ListView.builder tries to take up the whole screen, 
    you can't just "add" forms underneath it without causing a layout crash.
    To change this we need to change the body from a ListView.builder to a standard ListView (or CustomScrollView).
    */

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          // Changed from ListView.builder to a standard ListView
          padding: const EdgeInsets.all(16.0),
          children: [
            // SECTION 1: THE CART ITEMS
            const Text(
              "Your Order",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: cartItems.asMap().entries.map((entry) {
                int index = entry.key;
                var item = entry.value;
                return ListTile(
                  title: Text(item['name']),
                  trailing: Row(
                    // Use a Row to put two buttons side-by-side
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Move to favs button
                      IconButton(
                        tooltip: (item['isFavorite'] ?? false)
                            ? "Already in favorites - delete from cart to remove"
                            : "Move to favorites",

                        icon: Icon(
                          (item['isFavorite'] ?? false)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: (item['isFavorite'] ?? false)
                              ? Colors.red
                              : Colors.grey,
                        ),

                        // Optional: Custom color when disab
                        onPressed: (item['isFavorite'] ?? false)
                            ? null
                            : () {
                                // This updates the global coffeeProvider
                                ref
                                    .read(coffeeProvider.notifier)
                                    .toggleFavorite(item);
                                // 2. Remove the item from the cart provider
                                // Since you have the index from the ListView.builder, use it here
                                ref
                                    .read(cartProvider.notifier)
                                    .removeFromCart(index);
                                // Optional: Show a snackbar for feedback
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${item['name']} moved to Favorites!',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                      ),
                      // 2. Remove from cart button
                      IconButton(
                        tooltip: "Delete from cart",
                        icon: const Icon(Icons.delete_outline_outlined),
                        onPressed: () => ref
                            .read(cartProvider.notifier)
                            .removeFromCart(index),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const Divider(height: 40),

            // SECTION 2: PERSONAL INFO
            const Text(
              "Personal Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            PersonalInfoForm(
              nameController: _nameController,
              emailController: _emailController,
            ),

            const SizedBox(height: 20),
            // SECTION 3: BILLING & CARD
            const Text(
              "Payment Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            BillingInfoForm(
              cardController: _cardController,
              onCardChanged: (val) => setState(() {}),
            ),

            const SizedBox(height: 20),

            // SECTION 4: SHIPPING
            /*
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Shipping Address",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => _handleSync(true),
                  child: const Text("Same as billing?"),
                ),
              ],
            ),
            
            ShippingInfoForm(
              cityController: _shipCity,
              zipController: _shipZip,
            ),
            */

            const SizedBox(height: 40),
          ], //children
        ),
      ),
    );
  }
}

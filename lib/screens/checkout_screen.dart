import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';
import 'package:flutter_application_1/providers/coffee_provider.dart';
import 'package:flutter_application_1/services/address_service.dart';
import 'package:flutter_application_1/widgets/checkout/billing_info_form.dart';
import 'package:flutter_application_1/widgets/checkout/personal_info_form.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  // Define all your controllers here once
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _billCity = TextEditingController();
  final _billStatte = TextEditingController();
  final _billZip = TextEditingController();

  final _address01 = TextEditingController();
  final _address02 = TextEditingController();
  final _shipCity = TextEditingController();
  final _shipState = TextEditingController();
  final _shipZip = TextEditingController();

  final _cardController = TextEditingController();
  bool _sameAsBilling = false;

  void _handleSync(bool value) {
    setState(() {
      _sameAsBilling = value;
      if (_sameAsBilling) {
        _address01.text = '';
        _address02.text = '';
        _shipCity.text = _billCity.text;
        _shipState.text = _billStatte.text;
        _shipZip.text = _billZip.text;
      }
    });
  }

  @override
  void dispose() {
    // Clean up controllers when screen is closed
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _billCity.dispose();
    _billStatte.dispose();
    _billZip.dispose();
    _address01.dispose();
    _address02.dispose();
    _shipCity.dispose();
    _shipState.dispose();
    _shipZip.dispose();
    _cardController.dispose();
    super.dispose();
  }

  // when the user hits "Confirm & Pay," you will use Stripe to process the payment.
  Future<void> _processPayment() async {
    try {
      // 1. Create a "Payment Intent" (usually done via a small backend script)
      // 2. Present the Payment Sheet or confirm the card

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payment Successful!')));
    } catch (e) {
      // print('Payment failed: $e');
      debugPrint(e as String?);
    }
  }
  // End of Payment

  void _showAddressCheck(String original, String preferred) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Verify Shipping Address",
          style: TextStyle(fontFamily: 'Coolvetica'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "You entered:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(original),
            const SizedBox(height: 15),
            const Text(
              "Suggested (Preferred):",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(preferred),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _processPayment(); // Keep original
            },
            child: const Text(
              "KEEP ORIGINAL",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () {
              // Update fields with Google's data
              setState(() {
                _address01.text = preferred.split(',')[0];
                // Note: You may need more complex parsing to split City/State perfectly
              });
              Navigator.pop(context);
              _processPayment(); // Use preferred
            },
            child: const Text("USE PREFERRED"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

    final cartItems = ref.watch(cartProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ), // Standard web width
          child: Form(
            key: _formKey,
            child: ListView(
              // Changed from ListView.builder to a standard ListView
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20,
              ),
              children: [
                _sectionHeader("Your Order"),
                _buildCartSummary(cartItems),
                const Divider(height: 60),

                _sectionHeader("Personal Information"),
                PersonalInfoForm(
                  nameController: _nameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                ),
                const SizedBox(height: 30),

                _sectionHeader("Billing Address"),
                // I've added city/zip here so we can sync them to shipping
                _buildAddressFields(_billCity, _billStatte, _billZip),
                const SizedBox(height: 30),

                _sectionHeader("Payment Details"),
                BillingInfoForm(
                  cardController: _cardController,
                  onCardChanged: (val) => setState(() {}),
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionHeader("Shipping Address"),
                    Row(
                      children: [
                        const Text(
                          "Same as billing?",
                          style: TextStyle(fontSize: 12),
                        ),
                        Checkbox(
                          value: _sameAsBilling,
                          onChanged: (val) => _handleSync(val ?? false),
                        ),
                      ],
                    ),
                  ],
                ),
                if (!_sameAsBilling)
                  _buildAddressFields(
                    _shipCity,
                    _shipState,
                    _shipZip,
                    address01: _address01,
                    address02: _address02,
                  ),

                const SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Payment logic
                        // 1. Show a loading indicator
                        showDialog(
                          context: context,
                          builder: (c) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        // 2. Call Google API
                        AddressValidationResult? preferred =
                            await AddressService.validateAddress(
                              address1: _address01.text,
                              address2: _address02.text,
                              city: _shipCity.text,
                              state: _shipState.text,
                              zip: _shipZip.text,
                            );
                        if (!mounted) return;
                        Navigator.pop(context); // Remove loading indicator

                        String original =
                            "${_address01.text}, ${_shipCity.text}, ${_shipZip.text}";

                        if (preferred != null && preferred != original) {
                          // 3. Show the comparison if they don't match exactly
                          // _showAddressCheck(original, preferred);
                        } else {
                          // 4. Proceed if it's already perfect
                          _processPayment();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.black, // High contrast like gymshark
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "PLACE ORDER",
                      style: TextStyle(
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ], //children
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to keep build method clean
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Coolvetica',
          // fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAddressFields(
    TextEditingController city,
    TextEditingController zip,
    TextEditingController state, {
    TextEditingController? address01, // Optional named parameters
    TextEditingController? address02,
  }) {
    return Column(
      children: [
        // 1. Only render Autocomplete if address01 is actually provided
      if (address01 != null) ...[
        Autocomplete<Map<String, dynamic>>( // Fix: Use Map instead of dynamic
          optionsBuilder: (TextEditingValue textEditingValue) async {
            if (textEditingValue.text.length < 3) return const Iterable.empty();
            final results = await AddressService.getAutocompletePredictions(
              textEditingValue.text,
            );
            // Ensure we return an Iterable of Maps
            return List<Map<String, dynamic>>.from(results);
          },
          displayStringForOption: (option) => option['description'] ?? '',
          onSelected: (selection) async {
            _fillAddressFromPlaceId(selection['place_id']);
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            // Fix: Syncing controllers with null-safety
            if (address01.text.isNotEmpty && controller.text.isEmpty) {
              controller.text = address01.text;
            }
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                labelText: "Street, Building, Unit",
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              // Fix: Null check before assigning text
              onChanged: (val) => address01.text = val, 
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200, maxWidth: 552),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        title: Text(
                          option['description'] ?? '',
                          style: const TextStyle(fontSize: 13),
                        ),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
      ],
        // // Only show address lines if the controllers are passed in
        // if (address01 != null) ...[
        //   TextFormField(
        //     controller: address01,
        //     decoration: const InputDecoration(
        //       labelText: "Street, Building, Unit",
        //     ),
        //   ),
        //   const SizedBox(height: 10),
        // ],
        if (address02 != null) ...[
          TextFormField(
            controller: address02,
            decoration: const InputDecoration(labelText: "Apt No, Unit, Suite"),
          ),
          const SizedBox(height: 10),
        ],
        TextFormField(
          controller: city,
          decoration: const InputDecoration(labelText: "City"),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: state,
          decoration: const InputDecoration(labelText: "State"),
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: zip,
          decoration: const InputDecoration(labelText: "Zip Code"),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildCartSummary(List<Map<String, dynamic>> cartItems) {
    return Column(
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
                        ref.read(coffeeProvider.notifier).toggleFavorite(item);
                        // 2. Remove the item from the cart provider
                        // Since you have the index from the ListView.builder, use it here
                        ref.read(cartProvider.notifier).removeFromCart(index);
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
                onPressed: () =>
                    ref.read(cartProvider.notifier).removeFromCart(index),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _fillAddressFromPlaceId(String placeId) async {
    await AddressService.fetchPlaceDetails(
      placeId,
      address1: _address01,
      city: _shipCity,
      state: _shipState,
      zip: _shipZip,
    );
    setState(() {}); // Refresh UI to show the new auto-filled values
  }
}

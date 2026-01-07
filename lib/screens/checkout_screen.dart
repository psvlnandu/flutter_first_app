import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';
import 'package:flutter_application_1/providers/coffee_provider.dart';
import 'package:flutter_application_1/services/address_service.dart';
import 'package:flutter_application_1/widgets/checkout/billing_info_form.dart';
import 'package:flutter_application_1/widgets/checkout/personal_info_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

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

  final _billAddress01 = TextEditingController();
  final _billAddress02 = TextEditingController();
  final _billCity = TextEditingController();
  final _billState = TextEditingController();
  final _billZip = TextEditingController();

  final _shipAddress01 = TextEditingController();
  final _shipAddress02 = TextEditingController();
  final _shipCity = TextEditingController();
  final _shipState = TextEditingController();
  final _shipZip = TextEditingController();

  @override
  void initState() {
    super.initState();
    AddressService.initializeSessionToken();
  }

  final _cardController = TextEditingController();
  bool _sameAsBilling = false;

  void _handleSync(bool value) {
    setState(() {
      _sameAsBilling = value;
      if (_sameAsBilling) {
        _shipAddress01.text = _billAddress01.text;
        _shipAddress02.text = _billAddress02.text;
        _shipCity.text = _billCity.text;
        _shipState.text = _billState.text;
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

    _billAddress01.dispose();
    _billAddress02.dispose();
    _billCity.dispose();
    _billState.dispose();
    _billZip.dispose();

    _shipAddress01.dispose();
    _shipAddress02.dispose();
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
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          // Forces Coolvetica on every text style (Body, Title, Labels, Buttons)
          textTheme: Theme.of(
            context,
          ).textTheme.apply(fontFamily: 'coolvetica'),
        ),

        child: AlertDialog(
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
                List<String> parts = preferred.split(',');

                setState(() {
                  if (parts.isNotEmpty) _shipAddress01.text = parts[0].trim();

                  if (parts.length > 1) {
                    _shipCity.text = parts[1].trim();
                  }

                  if (parts.length > 2) {
                    // Handles "NY 13676" by splitting the space
                    List<String> stateZip = parts[2].trim().split(' ');
                    if (stateZip.isNotEmpty) _shipState.text = stateZip[0];
                    if (stateZip.length > 1) _shipZip.text = stateZip[1];
                  }
                });

                // 2. Close the dialog only
                Navigator.pop(context);

                // 3. Inform the user they can now proceed
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Address updated! Review and click Place Order.",
                    ),
                  ),
                );
              },
              child: const Text("USE PREFERRED"),
            ),
          ],
        ),
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
      body: Theme(
        data: Theme.of(context).copyWith(
          // Applies Coolvetica only to the body children
          textTheme: Theme.of(
            context,
          ).textTheme.apply(fontFamily: 'coolvetica'),
        ),
        child: Center(
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
                  _buildAddressFields(
                    address01: _billAddress01,
                    address02: _billAddress02,
                    city: _billCity,
                    state: _billState,
                    zip: _billZip,
                    label: "Billing",
                    isReadOnly: false,
                  ),
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
                            style: TextStyle(fontSize: 14),
                          ),
                          Checkbox(
                            value: _sameAsBilling,
                            onChanged: (val) => _handleSync(val ?? false),
                          ),
                        ],
                      ),
                    ],
                  ),

                  _buildAddressFields(
                    address01: _shipAddress01,
                    address02: _shipAddress02,
                    city: _shipCity,
                    state: _shipState,
                    zip: _shipZip,
                    label: "Shipping",
                    isReadOnly: _sameAsBilling,
                  ),

                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        // 1. Show Loading
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (c) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        AddressValidationResult? result =
                            await AddressService.validateAddress(
                              address1: _shipAddress01.text,
                              address2: _shipAddress02.text,
                              city: _shipCity.text,
                              state: _shipState.text,
                              zip: _shipZip.text,
                            );

                        if (!mounted) return;
                        Navigator.pop(context);
                        if (result == null) return;
                        if (result.isNonsense) {
                          _showSnackBar(
                            'Invalid Address: Street details not found.',
                            isError: true,
                          );
                          return;
                        }
                        if (result.isIncomplete || result.isSuspicious) {
                          debugPrint('SOFT_WARNING');
                          String original =
                              "${_shipAddress01.text}, ${_shipCity.text}, ${_shipState.text} ${_shipZip.text}";
                          _showAddressCheck(
                            original,
                            result.formattedAddress,
                          ); // Now this only happens for real places
                        }

                        // 4. Handle Authentication/Email
                        User? user = FirebaseAuth.instance.currentUser;
                        user ??=
                            (await FirebaseAuth.instance.signInAnonymously())
                                .user;

                        await user?.reload();
                        user = FirebaseAuth.instance.currentUser;

                        if (user?.email == null || !user!.emailVerified) {
                          _showEmailEntryDialog(
                            user!,
                            _emailController,
                          ); // This will trigger the FastAPI link
                          return;
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
      ),
    );
  }

  void _showEmailEntryDialog(User user, TextEditingController emailController) {
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(
            context,
          ).textTheme.apply(fontFamily: 'coolvetica'),
        ),
        child: AlertDialog(
          title: const Text(
            "Verify Your Email",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          // ADD THIS: Tell them which email the link is going to
          content: Text(
            "We will send a verification link to: \n${emailController.text}",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty) return;

                try {
                  // 2. Trigger your FastAPI proxy
                  final response = await http.post(
                    Uri.parse('http://127.0.0.1:3000/api/guest-verify'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'email': email,
                      'uid': user.uid, // Pass the anonymous UID
                    }),
                  );

                  if (!mounted) return;
                  Navigator.pop(context);

                  if (response.statusCode == 200) {
                    _showSnackBar("Verification link sent! Check your inbox.");
                    debugPrint('Guest_verify:$response');
                  }
                } catch (e) {
                  debugPrint("Error: $e");
                  _showSnackBar(
                    "Failed to send link. Please try again.",
                    isError: true,
                  );
                }
              },
              child: const Text("VERIFY NOW"),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'coolvetica', letterSpacing: 0.5),
        ),
        backgroundColor: isError ? Colors.red[900] : Colors.grey[900],
        behavior: SnackBarBehavior.floating, // Makes it look modern/detached
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white70,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
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
          fontSize: 16,
          // fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAddressFields({
    required TextEditingController address01,
    required TextEditingController address02,
    required TextEditingController city,
    required TextEditingController state,
    required TextEditingController zip,
    required String label,
    required bool isReadOnly,
  }) {
    return Column(
      children: [
        // ADDRESS LINE 1
        // Wrap Autocomplete to prevent interaction when locked
        IgnorePointer(
          ignoring: isReadOnly,
          child: Autocomplete<AddressAutocompleteOption>(
            optionsBuilder: (TextEditingValue textEditingValue) async {
              if (textEditingValue.text.length < 3) {
                return const Iterable.empty();
              }
              final results = await AddressService.getAutocompletePredictions(
                textEditingValue.text,
              );
              return results;
            },
            displayStringForOption: (option) => option.description,
            onSelected: (selection) async {
              await AddressService.fetchPlaceDetails(
                selection.placeId,
                address1: address01,
                address2: address02,
                city: city,
                state: state,
                zip: zip,
              );
              setState(() {});
            },
            fieldViewBuilder:
                (context, internalController, focusNode, onFieldSubmitted) {
                  if (internalController.text != address01.text) {
                    internalController.text = address01.text;
                  }
                  if (isReadOnly) internalController.text = address01.text;
                  return TextFormField(
                    controller: internalController,
                    focusNode: focusNode,
                    readOnly: isReadOnly,
                    decoration: InputDecoration(
                      labelText: "$label Address Line 1",
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      filled: isReadOnly,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (val) {
                      address01.text = val;
                    },
                    validator: (value) =>
                        value?.isEmpty ?? true ? "Address is required" : null,
                  );
                },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 250,
                      maxWidth: 552,
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(
                            option.mainText,
                            style: const TextStyle(fontSize: 14),
                          ),
                          subtitle: Text(
                            option.secondaryText,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
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
        ),
        const SizedBox(height: 16),

        // ADDRESS LINE 2
        TextFormField(
          controller: address02,
          readOnly: isReadOnly,
          decoration: InputDecoration(
            labelText: "$label Address Line 2 (Apt, Suite, etc)",
            filled: isReadOnly,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),

        // CITY & STATE ROW
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: city,
                decoration: InputDecoration(
                  labelText: "City",
                  filled: isReadOnly,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? "City is required" : null,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: TextFormField(
                controller: state,
                readOnly: isReadOnly,
                decoration: InputDecoration(
                  labelText: "State",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? "State is required" : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ZIP CODE
        TextFormField(
          controller: zip,
          readOnly: isReadOnly,
          decoration: InputDecoration(
            labelText: "Zip Code",
            filled: isReadOnly,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          keyboardType: TextInputType.number,
          validator: (value) =>
              value?.isEmpty ?? true ? "Zip code is required" : null,
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
      address1: _shipAddress01,
      city: _shipCity,
      state: _shipState,
      zip: _shipZip,
    );
    setState(() {}); // Refresh UI to show the new auto-filled values
  }
}

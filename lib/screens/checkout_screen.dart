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
                _shipAddress01.text = preferred.split(',')[0];
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
                        if (_formKey.currentState!.validate()) {
                          showDialog(
                            context: context,
                            builder: (c) => const Center(
                              child: CircularProgressIndicator(),
                            ),
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

                          if (result != null) {
                            // Only show dialog if address is actually problematic
                            if (result.isNonsense) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red[900],
                                  content: const Text(
                                    'Invalid Address: Street details not found. Please correct your input.',
                                  ),
                                ),
                              );
                              return; // STOP! Do not call _showAddressCheck
                            } // 2. SOFT WARNING: If it's valid but needs fixing/confirmation
                            if (result.isIncomplete || result.isSuspicious) {
                              debugPrint('SOFT_WARNING');
                              String original =
                                  "${_shipAddress01.text}, ${_shipCity.text}, ${_shipState.text} ${_shipZip.text}";
                              _showAddressCheck(
                                original,
                                result.formattedAddress,
                              ); // Now this only happens for real places
                            } else {
                              // 3. PERFECT: Just pay
                              _processPayment();
                            }
                          } else {
                            // Validation failed
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Address could not be validated. Please try again.',
                                ),
                              ),
                            );
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
                (context, controller, focusNode, onFieldSubmitted) {
                  if (isReadOnly) controller.text = address01.text;
                  return TextFormField(
                    controller: controller,
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

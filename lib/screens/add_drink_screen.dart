// screens/add_drink_screen.dart

import 'dart:io';
import 'package:flutter/foundation.dart'; // Required for kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/coffee_provider.dart';
import 'package:flutter_application_1/providers/drinkEntry_provider.dart';
import 'package:flutter_application_1/services/address_service.dart';
import 'package:flutter_application_1/widgets/coffee_search_bar.dart';
import 'package:flutter_application_1/widgets/unsplash_gallery.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/screens/home_screen.dart';

class AddDrinkScreen extends ConsumerStatefulWidget {
  const AddDrinkScreen({super.key}); // Good practice to include key
  @override
  _AddDrinkScreenState createState() => _AddDrinkScreenState();
}

class _AddDrinkScreenState extends ConsumerState<AddDrinkScreen> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    AddressService.initializeSessionToken();

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final notifier = ref.read(coffeeProvider.notifier);
      // Check if we are close to the bottom
      double triggerFetchThreshold =
          _scrollController.position.maxScrollExtent * 0.8;
      // If we are at 80% of the scroll height and not already loading...
      if (_scrollController.position.pixels >= triggerFetchThreshold) {
        if (!notifier.isLoading) {
          // Trigger the next page of the current search

          debugPrint('Add_DRINK-${notifier.isLoading}');
          notifier.searchCoffee(notifier.lastQuery);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Always clean up controllers!
    super.dispose();
  }

  String?
  _selectedImagePath; // we now stor string path?URL instead of File to handle both Unsplash and Local

  File? _selectedImage;
  double _rating = 0;
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _selectedImagePath = pickedFile.path);
    }
  }

  Widget starRating({
    required double rating,
    required Function(double) onRatingChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          // Added IconButton so it's actually clickable
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () => onRatingChanged(index + 1.0),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(drinkEntryProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Drink saved successfully!')),
          );
          // Navigator.pop(context); // You can also close the screen here
        },
        error: (error, stack) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $error')));
        },
      );
    });
    // This 'ref' now refers to the Riverpod WidgetRef, not the http package
    final state = ref.watch(drinkEntryProvider);
    final coffeeFeed = ref.watch(coffeeProvider);
    final entryState = ref.watch(drinkEntryProvider);
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Coolvetica'),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text("New Drink Album Entry")),
        body: Stack(
          // Wrap in a Stack to show a loading overlay
          children: [
            Row(
              children: [
                // 1. LEFT SIDE: Your current form
                Expanded(
                  flex: 2, // Takes up 40% of the screen
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        DragTarget<Map<String, dynamic>>(
                          onAccept: (data) {
                            setState(() {
                              _selectedImagePath =
                                  data['image']; // Capture the Unsplash URL!
                            });
                          },
                          builder: (context, candidateData, rejectedData) {
                            final bool isHovering = candidateData.isNotEmpty;
                            return Stack(
                              children: [
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    width: double.infinity,
                                    constraints: const BoxConstraints(
                                      minHeight:
                                          150, // Minimum height for the "Add" icon
                                      maxHeight:
                                          400, // Prevents giant images from taking over the screen
                                    ),
                                    decoration: BoxDecoration(
                                      color: isHovering
                                          ? Colors.brown.withOpacity(0.1)
                                          : Colors.grey[200],
                                      border: Border.all(
                                        color: isHovering
                                            ? Colors.brown
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: _selectedImagePath == null
                                        ? const Icon(Icons.add_a_photo)
                                        : ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child:
                                                (_selectedImagePath!.startsWith(
                                                      'http',
                                                    ) ||
                                                    kIsWeb)
                                                ? Image.network(
                                                    _selectedImagePath!,
                                                    fit: BoxFit.contain,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => const Icon(
                                                          Icons.broken_image,
                                                        ),
                                                  )
                                                : Image.file(
                                                    File(_selectedImagePath!),
                                                    fit: BoxFit.contain,
                                                  ),
                                          ),
                                  ),
                                ),
                                if (_selectedImagePath != null)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black.withOpacity(
                                        0.5,
                                      ),
                                      radius: 18,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _selectedImagePath =
                                                null; // Clear the image
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        // Reuse your Google Maps Autocomplete widget here
                        // TextField(
                        //   controller: _locationController,
                        //   decoration: const InputDecoration(
                        //     labelText: "Location",
                        //     suffixIcon: Icon(Icons.map),
                        //   ),
                        // ),
                        const SizedBox(height: 20),

                        // REPLACING YOUR OLD TEXTFIELD WITH AUTOCOMPLETE
                        Autocomplete<AddressAutocompleteOption>(
                          optionsBuilder: (TextEditingValue textEditingValue) async {
                            // Only search after 3 characters to save on API costs
                            if (textEditingValue.text.length < 3)
                              return const Iterable.empty();

                            // Calls your existing Google Places logic
                            return await AddressService.getAutocompletePredictions(
                              textEditingValue.text,
                            );
                          },
                          displayStringForOption: (option) =>
                              option.description,
                          onSelected: (selection) {
                            // Update your existing controller with the full address
                            setState(() {
                              _locationController.text = selection.description;
                            });
                          },
                          fieldViewBuilder:
                              (
                                context,
                                internalController,
                                focusNode,
                                onFieldSubmitted,
                              ) {
                                // This keeps the internal Google controller in sync with your form
                                if (internalController.text !=
                                    _locationController.text) {
                                  internalController.text =
                                      _locationController.text;
                                }

                                return TextField(
                                  controller: internalController,
                                  focusNode: focusNode,
                                  decoration: const InputDecoration(
                                    labelText: "Location",
                                    suffixIcon: Icon(Icons.map),
                                  ),
                                  onChanged: (val) =>
                                      _locationController.text = val,
                                );
                              },
                          // This styles the dropdown results list
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxHeight: 200,
                                    maxWidth: 350,
                                  ),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: options.length,
                                    itemBuilder: (context, index) {
                                      final option = options.elementAt(index);
                                      return ListTile(
                                        leading: const Icon(
                                          Icons.coffee_maker,
                                          color: Colors.brown,
                                        ),
                                        title: Text(
                                          option.mainText,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        subtitle: Text(
                                          option.secondaryText,
                                          style: const TextStyle(fontSize: 11),
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

                        starRating(
                          rating: _rating,
                          onRatingChanged: (val) =>
                              setState(() => _rating = val),
                        ),
                       
                        TextField(
                          controller: _notesController,
                          maxLength: 500,
                          decoration: const InputDecoration(
                            labelText: "Notes (Optional)",
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            if (_selectedImagePath == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please pick or drag an image first!",
                                  ),
                                ),
                              );
                              return;
                            }

                            debugPrint(
                              '_selectedImagePath: $_selectedImagePath',
                            );
                            final entry = DrinkEntry(
                              imagePath: _selectedImagePath!,
                              location: _locationController.text,
                              rating: _rating,
                              notes: _notesController.text,
                            );
                            ref
                                .read(drinkEntryProvider.notifier)
                                .saveEntry(entry)
                                .then((_) {
                                  final state = ref.read(drinkEntryProvider);
                                  if (state is AsyncError) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Firebase Error: ${state.error}",
                                        ),
                                      ),
                                    );
                                  } else if (mounted) {
                                    Navigator.pop(context);
                                  }
                                });
                          },
                          child: const Text("Save to Album"),
                        ),
                      ],
                    ),
                  ),
                ),
                // vertical divider
                const VerticalDivider(width: 1, thickness: 1),
                // RIGHT SIDE: Unsplash Gallery
                Expanded(
                  flex: 3, // Takes up 60% of the screen
                  child: Column(
                    children: [
                      const CoffeeSearchBar(hintText: 'Search inspo images...'),
                      Expanded(
                        child: UnsplashGallery(
                          controller: _scrollController,
                          crossAxisCount: 3,
                          isDraggable: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (entryState.isLoading)
              Container(
                color: Colors.black26, // Dims the screen
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.brown),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

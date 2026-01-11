// screens/add_drink_screen.dart

import 'dart:io';
import 'package:flutter/foundation.dart'; // Required for kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/drinkEntry_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:image_picker/image_picker.dart';

class AddDrinkScreen extends ConsumerStatefulWidget {
  const AddDrinkScreen({super.key}); // Good practice to include key
  @override
  _AddDrinkScreenState createState() => _AddDrinkScreenState();
}

class _AddDrinkScreenState extends ConsumerState<AddDrinkScreen> {
  File? _selectedImage;
  double _rating = 0;
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
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
    // This 'ref' now refers to the Riverpod WidgetRef, not the http package
    final state = ref.watch(drinkEntryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("New Drink Album Entry")),
      body: state.maybeWhen(
        loading: () => const Center(child: CircularProgressIndicator()),
        orElse: () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _selectedImage == null
                    ? Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Icon(Icons.add_a_photo),
                      )
                    : kIsWeb
                    ? Image.network(
                        _selectedImage!.path, // On web, this is a Blob URL
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        _selectedImage!, // On mobile, we use the file system
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),

              const SizedBox(height: 20),
              // Reuse your Google Maps Autocomplete widget here
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: "Location",
                  suffixIcon: Icon(Icons.map),
                ),
              ),
              starRating(
                rating: _rating,
                onRatingChanged: (val) => setState(() => _rating = val),
              ),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: "Notes (Optional)",
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_selectedImage == null) {
                    // Show a snackbar or alert: "Please pick an image!"
                    return;
                  }
                  final entry = DrinkEntry(
                    imagePath: _selectedImage!
                        .path, // Safe because of the null check above
                    location: _locationController.text,
                    rating: _rating,
                    notes: _notesController.text,
                  );
                  ref.read(drinkEntryProvider.notifier).saveEntry(entry).then((
                    _,
                  ) {
                    if (mounted) Navigator.pop(context);
                  });
                },
                child: const Text("Save to Album"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

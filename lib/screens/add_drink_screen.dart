// screens/add_drink_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/drinkEntry_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as ref;

class AddDrinkScreen extends ConsumerStatefulWidget {
  @override
  _AddDrinkScreenState createState() => _AddDrinkScreenState();
}

class _AddDrinkScreenState extends ConsumerState<AddDrinkScreen> {
  File? _selectedImage;
  double _rating = 0;
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _selectedImage = File(pickedFile.path));
  }

  @override
  Widget build(BuildContext context) {
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
                    ? Container(height: 200, color: Colors.grey[200], child: const Icon(Icons.add_a_photo))
                    : Image.file(_selectedImage!, height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 20),
              // Reuse your Google Maps Autocomplete widget here
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: "Location", suffixIcon: Icon(Icons.map)),
              ),
              StarRating(rating: _rating, onRatingChanged: (val) => setState(() => _rating = val)),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: "Notes (Optional)"),
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  final entry = DrinkEntry(
                    imagePath: _selectedImage?.path ?? '',
                    location: _locationController.text,
                    rating: _rating,
                    notes: _notesController.text,
                  );
                  ref.read(drinkEntryProvider.notifier).saveEntry(entry).then((_) => Navigator.pop(context));
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
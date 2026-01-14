import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';

/*
We will wrap the Auth and Firestore calls in a single process. 
If the Auth succeeds, we immediately create a document in the users collection 
using the uid (Unique ID) from the new account.
*/
class SignUpForm extends ConsumerStatefulWidget {
  const SignUpForm({super.key});

  @override
  ConsumerState<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends ConsumerState<SignUpForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _obscurePassword = true; // Start with the password hidden
  Future<void> _signUp() async {
    ref.read(authLoadingProvider.notifier).state = true;

    try {
      // 1. Create the user in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // 2. Save additional details to Firestore using the new UID
      if (userCredential.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'firstName': _firstNameController.text.trim(),
              'lastName': _lastNameController.text.trim(),
              'email': _emailController.text.trim(),
              'createdAt': Timestamp.now(),
            });
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Sign up failed"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextField(
            controller: _firstNameController,
            style: const TextStyle(fontFamily: 'Coolvetica'),
            decoration:  InputDecoration(labelText: 'First Name'),
          ),
          TextField(
            controller: _lastNameController,
            style: const TextStyle(fontFamily: 'Coolvetica'),
            decoration:  InputDecoration(labelText: 'Last Name'),
          ),
          TextField(
            controller: _emailController,
            style: const TextStyle(fontFamily: 'Coolvetica'),
            decoration:  InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _passwordController,
            style: const TextStyle(fontFamily: 'Coolvetica'),
            // 1. Use the variable here
            obscureText: _obscurePassword, 
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: const TextStyle(fontFamily: 'Coolvetica'),
              // 2. Add the toggle button
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _signUp,
                  child: const Text("Create Account"),
                ),
        ],
      ),
    );
  }
}

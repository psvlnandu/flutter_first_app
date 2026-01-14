import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';

class SignInForm extends ConsumerStatefulWidget {
  const SignInForm({super.key});

  @override
  ConsumerState<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<SignInForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final bool _isLoading = false;
  bool _obscurePassword = true; // Start with the password hidden

  Future<void> _signIn() async {
    ref.read(authLoadingProvider.notifier).state = true;
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // NOTE: We don't need a manual success SnackBar here anymore
      // if we use ref.listen to watch the auth state change globally.
    } on FirebaseAuthException catch (e) {
      String message = "Login failed";
      if (e.code == 'user-not-found')
        message = "No user found for that email.";
      else if (e.code == 'wrong-password')
        message = "Wrong password provided.";
      else if (e.code == 'invalid-email')
        message = "Invalid email format.";

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message,style: const TextStyle(fontFamily: 'coolvetica'),), backgroundColor: Colors.red),
      );
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider to update the UI
    final isLoading = ref.watch(authLoadingProvider);
    // 1. Reactive Listener for SUCCESS
    ref.listen(authStateProvider, (previous, next) {
      if (previous?.value == null && next.value != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Welcome back!"),
          ),
        );
      }
    });

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextField(
            controller: _emailController,
            style: const TextStyle(fontFamily: 'Coolvetica'),
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
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
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(onPressed: _signIn, child: const Text("Login")),
        ],
      ),
    );
  }
}

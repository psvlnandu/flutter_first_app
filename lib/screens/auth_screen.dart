import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/drawer/signIn_form.dart';
import 'package:flutter_application_1/widgets/drawer/signup_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
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
            child: TabBarView(
              children: [
                // Tab 1: Sign In
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20,
                  ),
                  child: SignInForm(), 
                ),
                // Tab 2: Sign Up
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20,
                  ),
                  child: SignUpForm(), 
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

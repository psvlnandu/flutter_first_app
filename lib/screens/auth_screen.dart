import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/drawer/signIn_form.dart';
import 'package:flutter_application_1/widgets/drawer/signup_form.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';

/*
Contains tabs
-> Sign in
-> Sign Up

-> modify the AuthScreen (which contains your tabs) so that it dynamically checks the user's login status.

*/
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context, Widget ref) {
    final user = FirebaseAuth.instance.currentUser;
    // This listens for state changes and triggers the SnackBar
    ref.listen(authProvider, (previous, next) {
      if (previous?.value != null && next.value == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Signed out!")));
      }
    });
    // If User is logged in, show Profile Info & Logout
    if (user != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile'), centerTitle: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                "Welcome back,",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                user.email ?? "User",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () async {
                  // 1. Capture the messenger before the async gap
                  final messenger = ScaffoldMessenger.of(context);

                  await FirebaseAuth.instance.signOut();

                  // 2. Show the snackbar
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text("Logged out successfully"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
              ),
            ],
          ),
        ),
      );
    }

    // If NOT logged in, show your existing Tab logic
    return DefaultTabController(
      // 1. Wrap everything in the controller
      length: 2,
      child: Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(
            context,
          ).textTheme.apply(fontFamily: 'coolvetica'),
        ),
        child: Scaffold(
          // 2. Use ONLY one Scaffold
          appBar: AppBar(
            title: const Text('Account'),
            centerTitle: true,
            elevation: 0,
            bottom: const TabBar(
              // 3. TabBar goes here
              tabs: [
                Tab(text: "Sign In"),
                Tab(text: "Sign Up"),
              ],
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: const TabBarView(
                // 4. TabBarView goes in the body
                children: [SignInForm(), SignUpForm()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

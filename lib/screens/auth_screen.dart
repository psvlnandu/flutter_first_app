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
NOTE:
-> In Riverpod, the ref object (which allows you to use ref.listen or ref.watch) 
  is only provided automatically in Consumer widgets. So always use class declaration StatefulWidget to ConsumerStatefulWidget.
  Change State<AuthScreen> to ConsumerState<AuthScreen>.

*/
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    // This listens for state changes and triggers the SnackBar
    ref.listen(authStateProvider, (previous, next) {
      if (previous?.value != null && next.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Signed out successfully!"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
    // Watch the auth state
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) => user != null ? _buildProfileView(user) : _buildAuthTabs(),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text("Error: $err"))),
    );
  }

  Widget _buildProfileView(User user) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Coolvetica'),
      ),
      child: Scaffold(
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
                onPressed: () => FirebaseAuth.instance.signOut(),
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthTabs() {
    return DefaultTabController(
      length: 2,
      child: Theme(
        data: Theme.of(context).copyWith(
          // 1. Apply to general text (Labels, Tab text, etc.)
          textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Coolvetica'),
          // 2. Apply specifically to TextFields (Labels and Hint text)
          inputDecorationTheme: const InputDecorationTheme(
            labelStyle: TextStyle(fontFamily: 'Coolvetica'),
            hintStyle: TextStyle(fontFamily: 'Coolvetica'),
          ),
          // 3. Apply specifically to Buttons
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontFamily: 'Coolvetica'),
            ),
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Account'),
            centerTitle: true,
            bottom: const TabBar(
              labelStyle: TextStyle(fontFamily: 'Coolvetica', fontWeight: FontWeight.bold),
              unselectedLabelStyle: TextStyle(fontFamily: 'Coolvetica'),
              tabs: [
                Tab(text: "Sign In"),
                Tab(text: "Sign Up"),
              ],
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: const TabBarView(children: [SignInForm(), SignUpForm()]),
            ),
          ),
        ),
      ),
    );
  }
}

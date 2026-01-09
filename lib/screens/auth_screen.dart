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

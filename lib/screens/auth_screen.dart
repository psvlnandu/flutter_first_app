
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
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Account"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Sign In"),
              Tab(text: "Sign Up"),
            ],
            indicatorColor: Colors.brown,
            labelColor: Colors.brown,
          ),
        ),
        body: const TabBarView(
          children: [
            SignInForm(),
            SignUpForm(),
          ],
        ),
      ),
    );
  }
}
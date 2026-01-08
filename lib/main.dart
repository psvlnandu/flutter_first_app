import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/favs_screen.dart';
import 'screens/checkout_screen.dart';
import 'env/env.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    debugPrint('Firebase initialized successfully!'); // Add this for confirmation
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
    
  }
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // // Initialize Stripe with your TEST KEY
  // Stripe.publishableKey = Env.pktest;
  // await Stripe.instance.applySettings();

  runApp(
    const ProviderScope(
      // This enables Riverpod for the whole app
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Old Market Coffee',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.brown,
        fontFamily: 'Melodrame',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          // This specifically overrides the AppBar title font
          titleTextStyle: TextStyle(
            fontFamily: 'LaGrazielaScriptDemo',
            fontSize: 36, // Adjust for that "Cute" script look
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/favs': (context) => const FavsScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/auth':(context)=>const AuthScreen();
      },
    );
  }
}

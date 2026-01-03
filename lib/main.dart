import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/favs_screen.dart';
import 'screens/checkout_screen.dart';

void main() => runApp(const MyApp());

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
        fontFamily: 'LaGrazielaScriptDemo', // Now the whole app uses your font!
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        // '/favs': (context) => const FavsScreen(),
        // '/checkout': (context) => const CheckoutScreen(),
      },
    );
  }
}

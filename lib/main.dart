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
        // '/favs': (context) => const FavsScreen(),
        '/checkout': (context) => const CheckoutScreen(),
      },
    );
  }
}

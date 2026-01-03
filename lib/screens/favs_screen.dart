import 'package:flutter/material.dart';

class FavsScreen extends StatefulWidget {
  const FavsScreen({super.key});
  @override
  State<FavsScreen> createState() => _FavsScreenState();
}

class _FavsScreenState extends State<FavsScreen> {
  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your favourites')),
      
      
    );
  }
}

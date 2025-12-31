import 'package:flutter/material.dart';

void main() {
  // starting point
  runApp(MyApp());
  // runApp(const ScaffoldExampleApp());
}

/*
Scaffold Widget
- Implements basic material design layout structure

*/
// immutable
  class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ScaffoldExample());
  }
}
// immutable
class ScaffoldExample extends StatefulWidget {
  const ScaffoldExample({super.key});

  @override
  State<ScaffoldExample> createState() => _ScaffoldExampleState();
}

// mutable
class _ScaffoldExampleState extends State<ScaffoldExample> {
  int _count = 0;
  final List _drinks = ['Matcha Latte', 'Cortado', 'Hot Chocolate'];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Old  Coffee')),
      body: Center(child: Text('you have selected ${_drinks[_count]} ')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _count++), // telling the class to re build
        tooltip: 'Increment Counter',
        child: const Icon(Icons.next_plan),
      ),
    );
  }
}

/*
class MyApp extends StatelessWidget {

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee App',
      home: Scaffold(
        appBar: AppBar(title: Text('Old Market Cafe')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DrinkName('Matcha Latte'),
              SizedBox(height: 8.0),

              DrinkName('Cortado'),
              SizedBox(height: 8.0),

              DrinkName('Hot Chocolate'),
              SizedBox(height: 8.0),
            ],
          ),
        ),
      ),
    );
  }
}
*/
/*
Statefull UI widgets-
- should update values from app over time.
- stateless widget can't update its values.
- statless is immutable
- State methods are created for stateful widgets.

Widgets are just blue prints
Element tree are what represented on the screen

*/

/*
We can make our own widget to prevent repeated coding & that's using stateless widget
*/

/*
class DrinkName extends StatelessWidget {

  final String name;

  const DrinkName(this.name);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.yellow),
      child: Padding(
        padding: const EdgeInsetsGeometry.all(8.0),
        child: Text(name),
      ),
    );
  }
}
*/

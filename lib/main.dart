import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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

  final List<Map<String, dynamic>> _coffeeMenu = [
    {
      'name': 'Matcha Latte',
      'image': 'assets/images/matcha_latte.jpg',
      'status': 'available',
      'isfavorite': false,
    },
    {
      'name': 'Cortado',
      'image': 'assets/images/cortado.jpg',
      'status': 'out_of_stock',
      'isfavorite': false,
    },
    {
      'name': 'Flat White',
      'image': 'assets/images/flat_white.jpg',
      'status': 'out_of_stock',
      'isfavorite': false,
    },
    {
      'name': 'Cappuccino',
      'image': 'assets/images/cappuccino.jpg',
      'status': 'available',
      'isfavorite': false,
    },
    {
      'name': 'Espresso',
      'image': 'assets/images/espresso.jpg',
      'status': 'available',
      'isfavorite': false,
    },
    {
      'name': 'Hot Chocolate',
      'image': 'assets/images/hot_choco.jpg',
      'status': 'available',
      'isfavorite': false,
    },
    {
      'name': 'Hot Latte',
      'image': 'assets/images/hot_latte.jpg',
      'status': 'available',
      'isfavorite': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Old Market Coffee',
          style: TextStyle(
            fontFamily:
                'LaGrazielaScriptDemo', // This must match the 'family' name in pubspec
            fontSize: 45,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: MasonryGridView.count(
        crossAxisCount: 4, // 2 columns like Pinterest
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        padding: const EdgeInsets.all(10),
        itemCount: _coffeeMenu.length,
        itemBuilder: (context, index) {
          final drink = _coffeeMenu[index];

          return Card(
            clipBehavior: Clip.antiAlias, // Ensures image corners are rounded
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              // Makes the whole card tappable
              onTap: () {
                bool isOut = drink['status'] == 'out_of_stock';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isOut
                          ? 'Oops! ${drink['name']} is out of stock.'
                          : '${drink['name']} added to cart!',
                    ),
                    backgroundColor: isOut
                        ? Colors.brown[400]
                        : Colors.pink[400],
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Column(
                children: [
                  Stack(
                    /*
                    The Stack Rule: Every widget inside a Stack is layered on top of the previous one, 
                    starting from the top-left corner by default.
                    */
                    children: [
                      // coffee Image
                      Image.asset(
                        drink['image'] ??
                            'assets/images/matcha_latte.jpg', // Default image
                        fit: BoxFit.cover,
                        // This is the Pinterest trick:
                        // Some images will be taller than others automatically
                        // based on the original image aspect ratio.
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            
                            color: Colors.brown[100],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.brown,
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              // Safety: if isFavorite is null, treat it as false
                              bool currentFav = drink['isFavorite'] ?? false;
                              drink['isFavorite'] = !currentFav;
                            });
                          },
                          child: Icon(
                            // Use ?? false here to prevent the 'Null' is not a 'bool' error
                            (drink['isFavorite'] ?? false)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: (drink['isFavorite'] ?? false)
                                ? Colors.red
                                : Colors.white,
                            shadows: const [
                              Shadow(color: Colors.black54, blurRadius: 10),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          drink['name']!,
                          style: TextStyle(
                            fontFamily:
                                'Melodrame', // This must match the 'family' name in pubspec
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown[900],
                          ),
                          //style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      /*
      ListView.builder(
        itemCount: _coffeeMenu.length,
        itemBuilder: (context, index) {
          final drink = _coffeeMenu[index];
          return Card(
            margin: const EdgeInsets.all(15),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  drink['image']!,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(drink['name']!),
              onTap: () {
                bool isOut = drink['status'] == 'out_of_stock';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isOut
                          ? 'Oops! ${drink['name']} is out of stock.'
                          : '${drink['name']} added to cart!',
                    ),
                    backgroundColor: isOut
                        ? Colors.brown[400]
                        : Colors.pink[400],
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          );
        },
      ),
      // Center(child: Text('you have selected ${_drinks[_count % _drinks.length]} ')),
      
      */
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            setState(() => _count++), // telling the class to re build
        tooltip: 'Increment Counter',
        child: const Icon(Icons.shopping_bag, color: Colors.brown),
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

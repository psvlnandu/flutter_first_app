import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../env/env.dart'; // Import your Env class

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
      'image': <String>[],
      'status': 'available',
      'isfavorite': false,
    },
    {
      'name': 'Cortado',
      'image':<String>[],
      'status': 'out_of_stock',
      'isfavorite': false,
    },
    {
      'name': 'Flat White',
      'image': <String>[],
      'status': 'out_of_stock',
      'isfavorite': false,
    },
    {
      'name': 'Cappuccino',
      'image':<String>[],
      'status': 'available',
      'isfavorite': false,
    },
    {
      'name': 'Espresso',
      'image':<String>[],
      'status': 'available',
      'isfavorite': false,
    },
    {
      'name': 'Hot Chocolate',
      'image': <String>[],
      'status': 'available',
      'isfavorite': false,
    },
    {
      'name': 'Hot Latte',
      'image': <String>[],
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
                      // FUTUREBUILDER: The bridge between your list and the API
                      FutureBuilder<List<String>>(
                        future: getCoffeeImageUrl(
                          drink['name'],
                        ), // Use drink name as search query
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // While waiting for the API response
                            return Container(
                              height: 150,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else if (snapshot.hasError ||
                              !snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            // Fallback if API fails or no image found
                            return Image.asset(
                              drink['image'],
                              fit: BoxFit.cover,
                            );
                          } else {
                            // SUCCESS: Use the first URL from your Unsplash function
                            return Image.network(
                              snapshot.data![0],
                              fit: BoxFit.cover,
                            );
                          }
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

Future<List<String>> getCoffeeImageUrl(String query) async {
  final String api_key = Env.apiKey; // Use your actual key
  final response = await http.get(
    Uri.parse('https://api.unsplash.com/search/photos?query=$query&per_page=10'),
    headers: {'Authorization': 'Client-ID $api_key'},
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    // Unsplash returns a list of results; we take the first one's 'regular' URL
    List<String> urls = [];
    for (var result in data['results']) {
      urls.add(result['urls']['regular']);
    }
    return urls;
  } else {
    throw Exception('Failed to load photos from Unsplash');
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

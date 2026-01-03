// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/coffee_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../env/env.dart'; // Import your Env class

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadFullFeed(); // Load the first page
    // Listen to scroll movements
    _scrollController.addListener(() {
      // If we are at 80% of the scroll height, load more!

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        if (!_isLoading) {
          _loadFullFeed();
        }
      }
    });
  }

  final List<Map<String, dynamic>> _coffeeMenu = [
    {
      'name': 'Matcha Latte',

      'image': <String>[],

      'status': 'available',

      'isfavorite': false,
    },

    {
      'name': 'Cortado',

      'image': <String>[],

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

      'image': <String>[],

      'status': 'available',

      'isfavorite': false,
    },

    {
      'name': 'Espresso',

      'image': <String>[],

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

  List<Map<String, dynamic>> _flattenedFeed = [];

  int _currentPage = 1;

  bool _isLoading = false;

  final ScrollController _scrollController = ScrollController();

  Future<void> _loadFullFeed() async {
    setState(() => _isLoading = true);
    List<Map<String, dynamic>> newItems = [];
    for (var drink in _coffeeMenu) {
      // Fetch 10 images for this specific drink
      List<String> urls = await getCoffeeImageBatch(
        drink['name'],
        _currentPage,
      );

      for (var url in urls) {
        newItems.add({
          'name': drink['name'],

          'image': url, // This is now a direct Network URL,

          'status': drink['status'],

          'isfavorite': false,
        });
      }
    }

    setState(() {
      _flattenedFeed.addAll(newItems);

      _flattenedFeed
          .shuffle(); // Make it look like a real Pinterest discovery feed

      _isLoading = false;
    });
  }

  // ... Paste your lists, scroll controller, and _loadFullFeed here ...
  final List<Map<String, dynamic>> _cart = []; // NEW: Your cart list

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Old Market Coffee'),
        
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.all(2.0),
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.brown),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Coffee Explorer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontFamily: 'Melodrame',
                    ),
                  ),
                ],
              ),
            ),
            // Item 1: Favorites
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.brown),
              title: const Text(
                'Favorites',
                style: TextStyle(fontFamily: 'Melodrame', fontSize: 24),
                
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer first
                
                Navigator.pushNamed(context, '/favs', arguments: _flattenedFeed);
              },
            ),
            // Item 2: Profile (Placeholder)
            ListTile(
              leading: const Icon(Icons.person, color: Colors.brown),
              title: const Text(
                'Profile',
                style: TextStyle(fontFamily: 'Melodrame',fontSize: 24),
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // We'll set this up later!
              },
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // AI Search Bar Placeholder
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Ask Gemini for a drink mood...',
                prefixIcon: const Icon(Icons.auto_awesome), // AI icon
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onSubmitted: (value) {
                // We will hook up Gemini here next!
              },
            ),
          ),
          Expanded(
            child: MasonryGridView.count(
              controller: _scrollController,
              crossAxisCount: 4, // Change to 2 for better mobile visibility
              itemCount: _flattenedFeed.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _flattenedFeed.length)
                  return const CircularProgressIndicator();
                final item = _flattenedFeed[index];
                return CoffeeCard(
                  item: item,
                  onToggleFavorite: () => setState(
                    () => item['isFavorite'] = !(item['isFavorite'] ?? false),
                  ),
                  onAddToCart: () => setState(() => _cart.add(item)),
                );
              },
            ),
          ),
        ],
      ),
      // NEW: DragTarget for the Cart!
      floatingActionButton: DragTarget<Map<String, dynamic>>(
        onAccept: (item) => setState(() => _cart.add(item)),
        builder: (context, candidateData, rejectedData) {
          // Check if an item is currently hovering over the cart
          bool isHovering = candidateData.isNotEmpty;
          // the candidateData parameter in your builder—it tells you if someone is currently holding a drink over the cart.
          return Transform.scale(
            scale: isHovering ? 1.2 : 1.0, // Scale up when hovering!
            child: FloatingActionButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/checkout', arguments: _cart),
              child: Badge(
                label: Text('${_cart.length}'),
                child: const Icon(Icons.shopping_bag),
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<List<String>> getCoffeeImageBatch(String query, int page) async {
  final String api_key = Env.apiKey; // Use your actual key

  // Notice 'per_page=10' in the URL - that's the key change!

  final response = await http.get(
    Uri.parse(
      'https://api.unsplash.com/search/photos?query=$query&per_page=10&page=$page',
    ),

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

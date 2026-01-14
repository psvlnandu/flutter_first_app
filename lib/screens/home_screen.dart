// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';
import 'package:flutter_application_1/providers/coffee_provider.dart';
import 'package:flutter_application_1/providers/drinkEntry_provider.dart';
import 'package:flutter_application_1/providers/favs_provider.dart';
import 'package:flutter_application_1/widgets/coffee_search_bar.dart';
import 'package:flutter_application_1/widgets/unsplash_gallery.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../env/env.dart'; // Import your Env class

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController =
      TextEditingController(); // Added for search

  String _currentSearchQuery = ""; // Track what we are currently showing
  int _currentPage = 1;

  bool _isLoading = false;

  // If query is empty, use your default menu.
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

  //In Flutter, functions that interact with controllers (like _scrollController) or update the UI (via setState) must stay inside the state class.
  void _scrollToTop() {
    // 1. Wait for the UI to actually finish building the new list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 2. Double check the controller is actually attached to a list
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

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
          debugPrint('HomeScreen-$_isLoading');
          _loadFullFeed();
        }
      }
    });
  }

  // Unified loading function to handle both feed and search
  Future<void> _loadFullFeed({String? query, bool isNewSearch = false}) async {
    setState(() => _isLoading = true);
    if (isNewSearch) {
      _currentPage = 1;
      _currentSearchQuery = query ?? "";
    }
    List<Map<String, dynamic>> newItems = [];
    // If query is empty, use your default menu, otherwise search specifically for that term
    final itemsToFetch = _currentSearchQuery.isEmpty
        ? _coffeeMenu
        : [
            {'name': _currentSearchQuery, 'status': 'available'},
          ];
    for (var drink in itemsToFetch) {
      try {
        List<Map<String, String>> images = await getCoffeeImageBatch(
          drink['name'],
          _currentPage,
        );
        for (var img in images) {
          newItems.add({
            'id': img['id'],
            'name': drink['name'],
            'image': img['url'],
            'status': drink['status'],
            'isFavorite': false,
          });
        }
      } catch (e) {
        debugPrint("Error fetching images: $e");
      }
    }

    // UPDATED: Push to Riverpod instead of local list
    if (_currentPage == 1) {
      ref.read(coffeeProvider.notifier).setFeed(newItems..shuffle());
      if (isNewSearch) {
        _scrollToTop();
      } // Scroll up when showing new search results
    } else {
      ref.read(coffeeProvider.notifier).addItems(newItems..shuffle());
    }

    _currentPage++;
    setState(() => _isLoading = false);
  }

  final List<Map<String, dynamic>> _cart = []; // NEW: Your cart list

  void _addToCart(Map<String, dynamic> item) {
    // Use ref.read for one-time actions like button clicks
    ref.read(cartProvider.notifier).addToCart(item);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${item['name']} added!')));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose(); // Clean up
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(coffeeProvider);
    final cart = ref.watch(cartProvider);
    final profileAsync = ref.watch(userProfileProvider);
      // 1. Watch your personal entries instead of Unsplash
    final userEntries = ref.watch(userEntriesStreamProvider);
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Coolvetica'),
      ),
      child: Scaffold(
        appBar: AppBar(
          // TRIGGER: Scroll to top on Title Click
          title: GestureDetector(
            onTap: _scrollToTop,
            child: const Text('Old Market Coffee'),
          ),

          actions: [
            // "+" to be in the top right corner
            IconButton(
              icon: const Icon(Icons.add, color: Colors.brown),
              onPressed: () => Navigator.pushNamed(context, '/add-drink'),
            ),
            profileAsync.when(
              data: (data) {
                if (data == null) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: InkWell(
                    // 1. Wrap in InkWell for tap functionality
                    onTap: () {
                      // 2. Navigate to the AuthScreen (Profile view)
                      Navigator.pushNamed(context, '/profile');
                    },
                    borderRadius: BorderRadius.circular(
                      20,
                    ), // Keeps ripple circular
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Hey, ${data['firstName'] ?? 'User'}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.brown, // Matches your theme
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.brown.shade100,
                            child: Text(
                              data['firstName']?[0].toUpperCase() ?? 'U',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const Icon(Icons.error_outline),
            ),
          ],
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

                  Navigator.pushNamed(context, '/favs');
                },
              ),
              // Item 2: Profile (Placeholder)
              ListTile(
                leading: const Icon(Icons.person, color: Colors.brown),
                title: const Text(
                  'Profile',
                  style: TextStyle(fontFamily: 'Melodrame', fontSize: 24),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.pushNamed(context, '/profile');
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
                  prefixIcon: const Icon(Icons.auto_awesome),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      //clear button
                      _searchController.clear();
                      ref
                          .read(coffeeProvider.notifier)
                          .searchCoffee("", isNewSearch: true);
                    },
                  ),

                  // AI icon
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onSubmitted: (value) => ref
                    .read(coffeeProvider.notifier)
                    .searchCoffee(value, isNewSearch: true),
                // _loadFullFeed(query: value, isNewSearch: true),
              ),
            ),
            
            Expanded(
                child: ref.watch(userEntriesStreamProvider).when(
                  data: (entries) {
                    if (entries.isEmpty) {
                      return const Center(
                        child: Text(
                          "Your diary is empty.\nTap + to add your first coffee!",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Coolvetica', fontSize: 18),
                        ),
                      );
                    }
                    
                    // Personal Pinterest Grid
                    return MasonryGridView.count(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      crossAxisCount: 4, 
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final drink = entries[index];
                        return _buildDiaryCard(drink); // The detailed card we'll build below
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: Colors.brown)),
                  error: (err, stack) => Center(child: Text("Error loading diary: $err")),
                ),
              ),
            // Use the loading state from your provider for the bottom indicator
            if (ref.watch(coffeeProvider.notifier).isLoading)
              const LinearProgressIndicator(color: Colors.brown),
          ],
        ),

        // DragTarget for the Cart!
        floatingActionButton: DragTarget<Map<String, dynamic>>(
          onAccept: (item) => ref.read(cartProvider.notifier).addToCart(item),
          builder: (context, candidateData, rejectedData) {
            // Check if an item is currently hovering over the cart
            bool isHovering = candidateData.isNotEmpty;
            // the candidateData parameter in your builder—it tells you if someone is currently holding a drink over the cart.
            return Transform.scale(
              scale: isHovering ? 1.2 : 1.0, // Scale up when hovering!
              child: FloatingActionButton(
                onPressed: () => Navigator.pushNamed(context, '/checkout'),
                child: Badge(
                  label: Text('${cart.length}'),
                  child: const Icon(Icons.shopping_bag),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget _buildDiaryCard(Map<String, dynamic> drink) {
  return GestureDetector(
    onTap: () {
      // Future: Navigate to Detail Page using drink['id']
      debugPrint("Clicked on drink: ${drink['id']}");
    },
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(
          drink['imageUrl'],
          fit: BoxFit.cover,
          // This ensures images load smoothly
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 150,
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.coffee, color: Colors.brown)),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            height: 150,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      ),
    ),
  );
}

Future<List<Map<String, String>>> getCoffeeImageBatch(
  String query,
  int page,
) async {
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

    List<Map<String, String>> items = [];

    for (var result in data['results']) {
      items.add({
        'id': result['id'], // Capture the unique Unsplash ID
        'url': result['urls']['regular'],
      });
    }

    return items;
  } else {
    debugPrint('Unsplash Error: ${response.statusCode} - ${response.body}');
    throw Exception('Failed to load photos from Unsplash');
  }
}

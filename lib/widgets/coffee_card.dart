import 'package:flutter/material.dart';

/*
This CoffeeCard is the visual building block of your shop's grid. It currently does two main things:
1.UI/UX: It displays the coffee image, name, and heart icon using a Stack. It also enables Drag and Drop (via the Draggable widget), which allows users to physically "pull" a coffee item into a cart or favorites area.
2. Logic Callbacks: it uses onToggleFavorite and onAddToCart to tell the parent widget (like HomeScreen or FavsScreen) when a user interacts with it.
*/
class CoffeeCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToCart;

  const CoffeeCard({
    super.key,
    required this.item,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<Map<String, dynamic>>(
      data: item,
      // What the user sees under their finger while dragging
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 150,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(item['image'], fit: BoxFit.cover),
          ),
        ),
      ),
      // What stays in the grid while dragging
      childWhenDragging: Opacity(opacity: 0.5, child: _buildBaseCard()),
      child: _buildBaseCard(),
    );
  }

  Widget _buildBaseCard() {
    return Card(
      clipBehavior: Clip.antiAlias, // Ensures image corners are rounded
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        // Makes the whole card tappable
        onTap: () {
          bool isOut = item['status'] == 'out_of_stock';
          if (!isOut) {
            onAddToCart();
          }
        },
        child: Column(
          children: [
            Stack(
              /*
                    The Stack Rule: Every widget inside a Stack is layered on top of the previous one, 
                    starting from the top-left corner by default.
                    */
              children: [
                Image.network(
                  item['image'],
                  fit: BoxFit.cover,
                  // The masonry layout loves images of different heights!
                ),

                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onToggleFavorite,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                      shadows: const [
                        Shadow(color: Colors.black54, blurRadius: 10),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    item['name']!,
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
  }
}

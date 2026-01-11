// widgets/star_rating.dart
import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final Function(double) onRatingChanged;

  const StarRating({required this.rating, required this.onRatingChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () => onRatingChanged(index + 1.0),
        );
      }),
    );
  }
}
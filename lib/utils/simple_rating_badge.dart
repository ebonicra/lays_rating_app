import 'package:flutter/material.dart';


class SimpleRatingBadge extends StatelessWidget {
  const SimpleRatingBadge({
    super.key,
    required this.rating,
    this.iconSize = 16,
    this.fontSize = 14,
  });

  final double rating;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isHigh = rating >= 4.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isHigh
            ? Colors.green.withValues(alpha: 0.2)
            : Colors.amber.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: iconSize, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
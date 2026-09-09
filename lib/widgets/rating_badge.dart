import 'package:flutter/material.dart';

/// Плашка с оценкой
class RatingBadge extends StatelessWidget {
  final int rating;
  final double iconSize;
  final double fontSize;

  const RatingBadge({
    super.key,
    required this.rating,
    this.iconSize = 18,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: _getRatingColors(rating),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _getRatingColors(rating)[0].withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: Colors.white, size: iconSize),
          const SizedBox(width: 4),
          Text(
            '$rating',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getRatingColors(int rating) {
    if (rating >= 5) return [Color(0xFF00E676), Color(0xFF1B5E20)];
    if (rating >= 4) return [Color(0xFFAED581), Color(0xFF00E676)];
    if (rating >= 3) return [Color(0xFFFFC107), Color(0xFFFF9800)];
    if (rating >= 2) return [Color(0xFFE65100), Color(0xFFFF9800)];
    return [Color(0xFFD32F2F), Color(0xFFB71C1C)];
  }
}
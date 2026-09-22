import 'package:flutter/material.dart';

/// Плашка с одной оценкой (например, оценка комментария).
class RatingBadge extends StatelessWidget {
  const RatingBadge({
    super.key,
    required this.rating,
    this.iconSize = 14,
    this.fontSize = 12,
  });

  final num rating;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = _ratingColors(rating);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
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
            _formatRating(),   // ← форматирование
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

  String _formatRating() {
    if (rating is int) return '$rating';
    if (rating is double && rating == rating.toInt()) return '${rating.toInt()}';
    return (rating as double).toStringAsFixed(1);
  }

  List<Color> _ratingColors(num rating) {
    if (rating >= 5) return const [Color(0xFF00E676), Color(0xFF1B5E20)];
    if (rating >= 4) return const [Color(0xFFAED581), Color(0xFF00E676)];
    if (rating >= 3) return const [Color(0xFFFFC107), Color(0xFFFF9800)];
    if (rating >= 2) return const [Color(0xFFE65100), Color(0xFFFF9800)];
    return const [Color(0xFFD32F2F), Color(0xFFB71C1C)];
  }
}
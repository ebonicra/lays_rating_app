import 'package:flutter/material.dart';

/// Цветная плашка со средней оценкой чипса.
class AverageRatingBadge extends StatelessWidget {
  const AverageRatingBadge({
    super.key,
    required this.rating,
    required this.count,
  });

  final double rating;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: _ratingColors(rating),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _ratingColors(rating)[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '($count ${_ratingWord(count)})',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Цвета градиента в зависимости от рейтинга.
  List<Color> _ratingColors(double rating) {
    const gold = Color(0xFFFFD700);
    const brightGreen = Color(0xFF00E676);
    const darkGreen = Color(0xFF1B5E20);
    const lightGreen = Color(0xFFAED581);
    const yellow = Color(0xFFFFEB3B);
    const deepYellow = Color(0xFFFFC107);
    const orange = Color(0xFFFF9800);
    const deepOrange = Color(0xFFE65100);
    const redOrange = Color(0xFFFF5722);
    const red = Color(0xFFD32F2F);
    const darkRed = Color(0xFFB71C1C);
    const grey = Color(0xFF757575);
    const darkGrey = Color(0xFF212121);

    if (rating >= 4.75) {
      final t = (rating - 4.75) / 0.25;
      return [
        Color.lerp(gold, brightGreen, t)!,
        Color.lerp(gold, darkGreen, t)!,
      ];
    } else if (rating >= 4.25) {
      final t = (rating - 4.25) / 0.5;
      return [
        Color.lerp(brightGreen, lightGreen, t)!,
        Color.lerp(darkGreen, lightGreen, t)!,
      ];
    } else if (rating >= 3.75) {
      final t = (rating - 3.75) / 0.5;
      return [
        Color.lerp(lightGreen, yellow, t)!,
        Color.lerp(darkGreen, yellow, t)!,
      ];
    } else if (rating >= 3.25) {
      final t = (rating - 3.25) / 0.5;
      return [
        Color.lerp(yellow, deepYellow, t)!,
        Color.lerp(yellow, orange, t)!,
      ];
    } else if (rating >= 2.75) {
      final t = (rating - 2.75) / 0.5;
      return [
        Color.lerp(deepYellow, orange, t)!,
        Color.lerp(orange, deepOrange, t)!,
      ];
    } else if (rating >= 2.25) {
      final t = (rating - 2.25) / 0.5;
      return [
        Color.lerp(orange, redOrange, t)!,
        Color.lerp(deepOrange, redOrange, t)!,
      ];
    } else if (rating >= 1.75) {
      final t = (rating - 1.75) / 0.5;
      return [
        Color.lerp(redOrange, red, t)!,
        Color.lerp(redOrange, darkRed, t)!,
      ];
    } else if (rating >= 1.25) {
      final t = (rating - 1.25) / 0.5;
      return [
        Color.lerp(red, darkRed, t)!,
        Color.lerp(darkRed, grey, t)!,
      ];
    } else if (rating >= 0.75) {
      final t = (rating - 0.75) / 0.5;
      return [
        Color.lerp(darkRed, grey, t)!,
        Color.lerp(darkRed, darkGrey, t)!,
      ];
    } else if (rating >= 0.25) {
      final t = (rating - 0.25) / 0.5;
      return [
        Color.lerp(grey, darkGrey, t)!,
        Color.lerp(darkGrey, Colors.black, t)!,
      ];
    } else {
      return [darkGrey, Colors.black];
    }
  }

  String _ratingWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'оценка';
    if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return 'оценки';
    }
    return 'оценок';
  }
}
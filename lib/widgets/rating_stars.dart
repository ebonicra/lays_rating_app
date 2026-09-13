import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final int? rating;
  final ValueChanged<int> onChanged;
  final double starSize;
  final Color? activeColor;
  final Color? inactiveColor;

  const RatingStars({
    super.key,
    required this.rating,
    required this.onChanged,
    this.starSize = 36,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? Colors.amber;
    final inactive = inactiveColor ?? Colors.grey.shade300;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) {
          final starNumber = index + 1;
          final isFilled = starNumber <= (rating ?? 0);

          return GestureDetector(
            onTap: () {
              if (rating == starNumber) {
                onChanged(0);
                return;
              }
              onChanged(starNumber);
            },
            child: AnimatedScale(
              scale: isFilled ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Icon(
                isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                size: starSize,
                color: isFilled ? active : inactive,
              ),
            ),
            // ),
          );
        },
      ),
    );
  }
}



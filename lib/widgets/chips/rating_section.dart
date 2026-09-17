import 'package:flutter/material.dart';

import 'package:lays_rating/models/chip.dart';
import 'package:lays_rating/models/chip_preference.dart';
import 'package:lays_rating/widgets/chips/average_rating_badge.dart';
import 'package:lays_rating/widgets/chips/rating_stars.dart';

/// Блок «Твоя оценка + Средняя оценка».
class RatingSection extends StatelessWidget {
  const RatingSection({
    super.key,
    required this.chip,
    required this.preference,
    required this.onRatingChanged,
  });

  final LaysChip chip;
  final ChipPreference preference;
  final ValueChanged<int> onRatingChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Твоя оценка
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Твоя оценка:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              RatingStars(
                rating: preference.rating ?? 0,
                onChanged: onRatingChanged,
                starSize: 30,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Средняя оценка
        Expanded(
          flex: 2,
          child: AverageRatingBadge(
            rating: chip.rating.average,
            count: chip.rating.count,
          ),
        ),
      ],
    );
  }
}
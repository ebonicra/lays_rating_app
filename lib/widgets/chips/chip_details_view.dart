import 'package:flutter/material.dart';

import 'package:lays_rating/models/chip.dart';
import 'package:lays_rating/models/chip_preference.dart';
import 'package:lays_rating/widgets/chips/chip_flip_card.dart';
import 'package:lays_rating/widgets/chips/chip_preference_actions.dart';
import 'package:lays_rating/widgets/chips/rating_section.dart';
import 'package:lays_rating/widgets/chips/comments/comments_section.dart';

class ChipDetailsView extends StatelessWidget {
  const ChipDetailsView({
    super.key,
    this.commentsKey,
    required this.chip,
    required this.preference,
    required this.onRatingChanged,
    required this.onFavoriteChanged,
    required this.onTriedChanged,
    this.onAverageRatingLongPress,
  });

  final GlobalKey<CommentsSectionState>? commentsKey;
  final LaysChip chip;
  final ChipPreference preference;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onFavoriteChanged;
  final VoidCallback onTriedChanged;
  final VoidCallback? onAverageRatingLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChipFlipCard(chip: chip),
          const SizedBox(height: 24),

          // Название
          Center(
            child: Text(
              chip.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),

          // Описание
          Text(
            chip.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
              fontSize: 14,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          // Рейтинг
          RatingSection(
            chip: chip,
            preference: preference,
            onRatingChanged: onRatingChanged,
            onAverageRatingLongPress: onAverageRatingLongPress,
          ),
          const SizedBox(height: 20),

          // Действия
          ChipPreferenceActions(
            isFavorite: preference.isFavorite,
            isTried: preference.isTried,
            onFavoriteChanged: onFavoriteChanged,
            onTriedChanged: onTriedChanged,
          ),
          const SizedBox(height: 24),

          // Комментарии
          CommentsSection(
            key: commentsKey,
            chipId: chip.id
          ),
        ],
      ),
    );
  }
}
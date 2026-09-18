import 'package:flutter/material.dart';

import 'package:lays_rating/models/news_item.dart';
import 'package:lays_rating/models/poll.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/widgets/news/poll_option_tile.dart';
import 'package:lays_rating/widgets/news/news_images_carousel.dart';

/// Содержимое новости «опрос».
class PollContent extends StatelessWidget {
  const PollContent({
    super.key,
    required this.item,
    required this.onVote,
    required this.onRemoveVote,
  });

  final NewsItem item;

  /// Колбэк при голосовании (индекс варианта).
  final ValueChanged<int> onVote;

  /// Колбэк при отмене голоса.
  final VoidCallback onRemoveVote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final poll = item.poll;

    if (poll == null) return const SizedBox.shrink();

    final hasVoted = poll.myVote != null;
    final hasImages = poll.options.any((o) => o.imagePath != null);
    final imageSize = _imageSize(poll.options.length);

    final paths = poll.options
      .where((o) => o.imagePath != null)
      .map((o) => o.imagePath!)
      .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.poll_rounded,
              size: 14,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            const Text(
              'Опрос',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            poll.question,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (hasImages) ...[


          NewsImagesCarousel(imagePaths: paths)
        ],
        const SizedBox(height: 12),
        ...poll.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          return PollOptionTile(
            option: option,
            totalVotes: poll.totalVotes,
            isMyVote: poll.myVote == index,
            hasVoted: hasVoted,
            onTap: hasVoted ? null : () => onVote(index),
          );
        }),
        if (item.text != null && item.text!.isNotEmpty)
          Center(
            child: Text(
              item.text!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.3,
                fontSize: 16,
              ),
            ),
          ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              '${poll.totalVotes} ${_pluralizeVotes(poll.totalVotes)}',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            if (hasVoted)
              TextButton.icon(
                onPressed: onRemoveVote,
                icon: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: theme.colorScheme.error,
                ),
                label: Text(
                  'Отменить голос',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.error,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
      ],
    );
  }

  double _imageSize(int count) {
    if (count == 1) return 180;
    if (count == 2) return 140;
    if (count == 3) return 110;
    return 85;
  }

  String _pluralizeVotes(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'голос';
    if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return 'голоса';
    }
    return 'голосов';
  }
}

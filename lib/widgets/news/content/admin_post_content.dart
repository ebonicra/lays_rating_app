import 'package:flutter/material.dart';

import 'package:lays_rating/models/news_item.dart';
import 'package:lays_rating/widgets/news/news_images_carousel.dart';

/// Содержимое новости «от админа».
class AdminPostContent extends StatelessWidget {
  const AdminPostContent({
    super.key,
    required this.item,
  });

  final NewsItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chips = item.extraData?['chips'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.campaign_rounded,
              size: 14,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            const Text(
              'От админа',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // if (chips.isNotEmpty) ...[
        //   _AdminPostImagesRow(chips: chips),
        //   const SizedBox(height: 12),
        // ],

        if (chips.isNotEmpty) ...[
          NewsImagesCarousel(
            imagePaths: chips
                .map((c) => c['image_path'] as String)
                .toList(),
          ),
          const SizedBox(height: 12),
        ],
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
      ],
    );
  }
}

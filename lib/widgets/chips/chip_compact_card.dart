import 'package:flutter/material.dart';

import 'package:lays_rating/models/chip.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/widgets/chips/chip_details_page.dart';

const double _imageWidth = 100;
const double _imageHeight = 130;

/// Компактная карточка чипса для списка.
class ChipCompactCard extends StatelessWidget {
  const ChipCompactCard({
    super.key,
    required this.chip,
    this.onReturn,
  });

  final LaysChip chip;
  final VoidCallback? onReturn;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChipDetailsPage(chipId: chip.id),
            ),
          );
          onReturn?.call();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  '${AuthService.baseUrl}/chips/images/${chip.imagePath}',
                  width: _imageWidth,
                  height: _imageHeight,
                  cacheWidth: (_imageWidth * MediaQuery.devicePixelRatioOf(context)).round(),
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      width: _imageWidth,
                      height: _imageHeight,
                      color: colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: _imageWidth,
                      height: _imageHeight,
                      color: colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: _imageHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chip.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          // height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        chip.category.title,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            chip.available
                                ? Icons.shopping_bag_outlined
                                : Icons.inventory_2_outlined,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            chip.available ? 'В продаже' : 'Архивный вкус',
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            chip.rating.average.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' (${chip.rating.count})',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 17,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            chip.commentCount.toString(),
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          if (chip.isFavorite) ...[
                            Icon(
                              Icons.favorite,
                              size: 16,
                              color: Colors.red.withValues(alpha: 0.7),
                            ),
                          ],
                          if (chip.isTried) ...[
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.green.withValues(alpha: 0.7),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
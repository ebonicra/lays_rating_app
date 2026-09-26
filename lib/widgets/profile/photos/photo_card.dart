import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:lays_rating/constants/photo_constants.dart';
import 'package:lays_rating/models/photo/photo.dart';
import 'package:lays_rating/services/auth_service.dart';

/// Карточка одного фото в карусели: изображение и счётчик лайков.
class PhotoCard extends StatelessWidget {
  const PhotoCard({
    super.key,
    required this.photo,
    required this.onTap,
    required this.onLikeTap,
    required this.onCountTap,
  });

  final Photo photo;
  final VoidCallback onTap;
  final VoidCallback onLikeTap;
  final VoidCallback onCountTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          GestureDetector(
            onTap: onTap,
            child: CachedNetworkImage(
              imageUrl: '${AuthService.baseUrl}/photos/images/${photo.imagePath}',
              width: PhotoConstants.cardSize,
              height: PhotoConstants.cardSize,
              fit: BoxFit.cover,
              memCacheWidth: (PhotoConstants.cardSize * MediaQuery.devicePixelRatioOf(context)).round(),
              placeholder: (context, url) => Container(
                width: PhotoConstants.cardSize,
                height: PhotoConstants.cardSize,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => Container(
                width: PhotoConstants.cardSize,
                height: PhotoConstants.cardSize,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Center(child: Icon(Icons.broken_image)),
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            left: 4,
            child: GestureDetector(
              onTap: onLikeTap,
              onLongPress: onCountTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      photo.isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      size: 16,
                      color: photo.isLiked ? Colors.red : Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${photo.likesCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/widgets/common/full_screen_gallery.dart';

/// Карусель изображений обратной связи.
class FeedbackImagesCarousel extends StatelessWidget {
  const FeedbackImagesCarousel({
    super.key,
    required this.imagePaths,
  });

  final List<String> imagePaths;

  static const double _carouselHeight = 200;
  static const double _carouselItemWidth = 200;

  @override
  Widget build(BuildContext context) {
    if (imagePaths.isEmpty) return const SizedBox.shrink();
    return _buildCarousel(context);
  }

  Widget _buildCarousel(BuildContext context) {
    return SizedBox(
      height: _carouselHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: imagePaths.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return _Tile(
            path: imagePaths[index],
            width: _carouselItemWidth,
            height: _carouselHeight,
            onTap: () => _openFullScreen(context, index),
          );
        },
      ),
    );
  }

  void _openFullScreen(BuildContext context, int initialIndex) {
    final urls = imagePaths
        .map((path) => '${AuthService.baseUrl}/feedback/images/$path')
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenGallery(
          imageUrls: urls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.path,
    required this.width,
    required this.height,
    required this.onTap,
  });

  final String path;
  final double width;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: '${AuthService.baseUrl}/feedback/images/$path',
          width: width,
          height: height,
          fit: BoxFit.cover,
          memCacheWidth:
              (width * MediaQuery.devicePixelRatioOf(context)).round(),
          placeholder: (context, url) => Container(
            width: width,
            height: height,
            color: colorScheme.surfaceContainerHighest,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: width,
            height: height,
            color: colorScheme.surfaceContainerHighest,
            child: const Center(child: Icon(Icons.broken_image)),
          ),
        ),
      ),
    );
  }
}
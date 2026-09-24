import 'package:flutter/material.dart';

import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/widgets/common/full_screen_gallery.dart';


/// Карусель изображений новости
class NewsImagesCarousel extends StatelessWidget {
  const NewsImagesCarousel({
    super.key,
    required this.imagePaths,
  });

  final List<String> imagePaths;
  static const double _singleImageSize = 240;
  static const double _carouselHeight = 150;
  static const double _carouselItemWidth = 150;

  @override
  Widget build(BuildContext context) {
    if (imagePaths.isEmpty) return const SizedBox.shrink();

    if (imagePaths.length == 1) {
      return _buildSingle(context);
    }

    return _buildCarousel(context);
  }

  Widget _buildSingle(BuildContext context) {
    return Center(
      child: _ImageTile(
        path: imagePaths.first,
        width: _singleImageSize,
        height: _singleImageSize,
        onTap: () => _openFullScreen(context, 0),
      ),
    );
  }

  Widget _buildCarousel(BuildContext context) {
    return SizedBox(
      height: _carouselHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: imagePaths.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return _ImageTile(
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
        .map((path) => '${AuthService.baseUrl}/news/images/$path')
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

/// Одна картинка с плейсхолдером и обработкой ошибок.
class _ImageTile extends StatelessWidget {
  const _ImageTile({
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
        child: Image.network(
          '${AuthService.baseUrl}/news/images/$path',
          width: width,
          height: height,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              width: width,
              height: height,
              color: colorScheme.surfaceContainerHighest,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: colorScheme.surfaceContainerHighest,
              child: Center(
                child: Icon(
                  Icons.broken_image,
                  color: colorScheme.onSurfaceVariant,
                  size: 32,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
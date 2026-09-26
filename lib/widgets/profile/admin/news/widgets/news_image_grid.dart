import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';


import 'package:lays_rating/models/news_image.dart';
import 'package:lays_rating/services/auth_service.dart';

const double _itemSize = 160;
const double _gap = 8;

/// Горизонтальная карусель картинок для формы новости.
///
/// Работает с [NewsImage] — локальными (ещё не загруженными)
/// и серверными (уже на сервере).
class NewsImageGrid extends StatelessWidget {
  const NewsImageGrid({
    super.key,
    required this.images,
    required this.onAdd,
    required this.onRemove,
    this.maxImages = 10,
  });

  final List<NewsImage> images;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final int maxImages;

  bool get _canAddMore => images.length < maxImages;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _itemSize,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: images.length + (_canAddMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(width: _gap),
        itemBuilder: (context, index) {
          if (index == images.length) {
            return _AddButton(onTap: onAdd);
          }
          return _ImagePreview(
            image: images[index],
            onRemove: () => onRemove(index),
          );
        },
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.image,
    required this.onRemove,
  });

  final NewsImage image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildImage(context),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.6),
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    if (image.isLocal) {
      return Image.file(
        File(image.localPath!),
        width: _itemSize,
        height: _itemSize,
        fit: BoxFit.cover,
      );
    }

    // remote
    final url = '${AuthService.baseUrl}/news/images/${image.remotePath}';

    return CachedNetworkImage(
      imageUrl: url,
      width: _itemSize,
      height: _itemSize,
      fit: BoxFit.cover,
      memCacheWidth: (_itemSize * MediaQuery.devicePixelRatioOf(context)).round(),
      placeholder: (context, url) => Container(
        width: _itemSize,
        height: _itemSize,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => Container(
        width: _itemSize,
        height: _itemSize,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: Icon(Icons.broken_image)),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _itemSize,
        height: _itemSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outlineVariant,
            width: 1.5,
          ),
        ),
        child: Icon(
          Icons.add_photo_alternate_outlined,
          color: colorScheme.onSurfaceVariant,
          size: 28,
        ),
      ),
    );
  }
}
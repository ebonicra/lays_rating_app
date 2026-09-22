import 'dart:io';

import 'package:flutter/material.dart';

const double _itemSize = 160;
const double _gap = 8;

/// Горизонтальная карусель картинок для формы новости
class NewsImageGrid extends StatelessWidget {
  const NewsImageGrid({
    super.key,
    required this.imagePaths,
    required this.onAdd,
    required this.onRemove,
    this.maxImages = 10,
  });

  final List<String> imagePaths;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final int maxImages;

  bool get _canAddMore => imagePaths.length < maxImages;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _itemSize,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: imagePaths.length + (_canAddMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(width: _gap),
        itemBuilder: (context, index) {
          if (index == imagePaths.length) {
            return _AddButton(onTap: onAdd);
          }
          return _ImagePreview(
            path: imagePaths[index],
            onRemove: () => onRemove(index),
          );
        },
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.path,
    required this.onRemove,
  });

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(path),
            width: _itemSize,
            height: _itemSize,
            fit: BoxFit.cover,
          ),
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
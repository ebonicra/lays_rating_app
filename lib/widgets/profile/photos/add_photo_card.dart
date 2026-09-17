import 'package:flutter/material.dart';

import 'package:lays_rating/constants/photo_constants.dart';

// Карточка «Добавить фото».
class AddPhotoCard extends StatelessWidget {
  const AddPhotoCard({
    super.key,
    required this.onTap,
    this.fullWidth = false,
  });

  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? null : PhotoConstants.cardSize,
        height: fullWidth ? null : PhotoConstants.cardSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.add_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Добавить фото',
              style: TextStyle(
                fontSize: fullWidth ? 12 : 8,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
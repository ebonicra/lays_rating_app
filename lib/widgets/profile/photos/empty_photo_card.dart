import 'package:flutter/material.dart';

import 'package:lays_rating/constants/photo_constants.dart';

/// Карточка для пустого состояния фото.
///
/// Если [onTap] == null — простая заглушка с иконкой и текстом.
/// Если [onTap] != null — карточка «добавить фото» с тапом.
class EmptyPhotoCard extends StatelessWidget {
  const EmptyPhotoCard({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.fullWidth = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
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
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.2),
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
                color: colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                icon,
                size: 18,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: fullWidth ? 12 : 10,
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
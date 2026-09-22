import 'package:flutter/material.dart';

// Плашка «Подписан на вас» / «Не подписан на вас».
class ProfileFollowsMeBadge extends StatelessWidget {
  const ProfileFollowsMeBadge({
    super.key,
    required this.isFollowingMe,
  });

  final bool isFollowingMe;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final active = isFollowingMe;
    final color =
        active ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: active
            ? colorScheme.primaryContainer.withOpacity(0.5)
            : colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: active
              ? colorScheme.primary.withOpacity(0.3)
              : colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            active
                ? Icons.check_circle_rounded
                : Icons.cancel_outlined,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            active ? 'Подписан на вас' : 'Не подписан на вас',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
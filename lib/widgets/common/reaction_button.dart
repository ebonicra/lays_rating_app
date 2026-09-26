import 'package:flutter/material.dart';

/// Кнопка реакции (лайк / дизлайк) с иконкой и счётчиком
class ReactionButton extends StatelessWidget {
  const ReactionButton({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.count,
    required this.isActive,
    required this.activeColor,
    required this.isLoading,
    required this.onTap,
    this.onLongPress,
  });

  final IconData icon;
  final IconData activeIcon;
  final int count;
  final bool isActive;
  final Color activeColor;
  final bool isLoading;
  final VoidCallback onTap;

  /// Долгое нажатие — например, чтобы открыть список тех, кто лайкнул/дизлайкнул.
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isActive ? activeColor : colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: isLoading ? null : onTap,
      onLongPress: isLoading ? null : onLongPress,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 1),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
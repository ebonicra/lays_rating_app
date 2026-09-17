import 'package:flutter/material.dart';

/// Компактная кнопка-действие с иконкой, подписью и анимацией нажатия.
///
/// Используется для «Любимчик» и «Пробовал» в карточке чипса.
class MiniActionButton extends StatefulWidget {
  const MiniActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  State<MiniActionButton> createState() => _MiniActionButtonState();
}

class _MiniActionButtonState extends State<MiniActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: widget.onTap,
      onHighlightChanged: (value) => setState(() => _pressed = value),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedScale(
        scale: _pressed ? 0.8 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: widget.active
                ? colorScheme.inversePrimary.withOpacity(0.8)
                : colorScheme.surface,
            border: Border.all(
              color: widget.active
                  ? colorScheme.inversePrimary
                  : colorScheme.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.active
                    ? colorScheme.inversePrimary.withOpacity(0.8)
                    : colorScheme.outlineVariant.withOpacity(0.8),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: widget.active
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: widget.active
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
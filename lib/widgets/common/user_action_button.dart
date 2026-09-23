import 'package:flutter/material.dart';

/// Кнопка действия в карточке пользователя с анимацией нажатия.
class UserActionButton extends StatefulWidget {
  const UserActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  State<UserActionButton> createState() => _UserActionButtonState();
}

class _UserActionButtonState extends State<UserActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.8 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: ElevatedButton(
          onPressed: widget.onTap,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            minimumSize: const Size(110, 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: widget.active
                ? colorScheme.surfaceContainerHighest
                : colorScheme.primary,
            foregroundColor: widget.active
                ? colorScheme.onSurface
                : colorScheme.onPrimary,
            elevation: 2,
          ),
          child: Text(
            widget.label,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }
}
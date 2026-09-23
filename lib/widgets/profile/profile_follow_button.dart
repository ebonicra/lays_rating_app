import 'package:flutter/material.dart';

/// Кнопка «Подписаться» / «Отписаться» с анимацией нажатия.
class ProfileFollowButton extends StatefulWidget {
  const ProfileFollowButton({
    super.key,
    required this.isFollowing,
    required this.isLoading,
    required this.onTap,
  });

  final bool isFollowing;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  State<ProfileFollowButton> createState() => _ProfileFollowButtonState();
}

class _ProfileFollowButtonState extends State<ProfileFollowButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final active = widget.isFollowing;

    return AnimatedScale(
      scale: _pressed ? 0.8 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: InkWell(
        onTap: widget.isLoading ? null : widget.onTap,
        onHighlightChanged: (value) {
          setState(() => _pressed = value);
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: active
                ? colorScheme.inversePrimary.withOpacity(0.8)
                : colorScheme.surface,
            border: Border.all(
              color: active
                  ? colorScheme.inversePrimary
                  : colorScheme.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: active
                    ? colorScheme.inversePrimary.withOpacity(0.8)
                    : colorScheme.outlineVariant.withOpacity(0.8),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SizedBox(
            height: 20,
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      active ? 'Отписаться' : 'Подписаться',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: active
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
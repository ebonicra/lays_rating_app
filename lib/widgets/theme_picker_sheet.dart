import 'dart:math' as math;
import 'package:flutter/material.dart';

class ThemeWheelDialog extends StatefulWidget {
  final ThemeMode currentTheme;
  final ValueChanged<ThemeMode> onThemeChanged;

  const ThemeWheelDialog({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  State<ThemeWheelDialog> createState() => _ThemeWheelDialogState();
}

class _ThemeWheelDialogState extends State<ThemeWheelDialog>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;
  late Animation<double> _scaleAnimation;

  late AnimationController _closeController;
  late Animation<double> _closeScaleAnimation;
  late Animation<double> _closeRotateAnimation;

  @override
  void initState() {
    super.initState();

    // Появление
    _spinController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _spinAnimation = CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutBack),
    );

    // Исчезновение
    _closeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _closeScaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _closeController, curve: Curves.easeInBack),
    );

    _closeRotateAnimation = Tween<double>(begin: 0.0, end: 3 * math.pi).animate(
      CurvedAnimation(parent: _closeController, curve: Curves.easeInCubic),
    );

    _spinController.forward();
  }

  @override
  void dispose() {
    _spinController.dispose();
    _closeController.dispose();
    super.dispose();
  }

  Future<void> _selectTheme(ThemeMode mode) async {
    await _closeController.forward();

    if (mounted) {
      widget.onThemeChanged(mode);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: Listenable.merge([_spinAnimation, _closeScaleAnimation]),
        builder: (context, child) {
          final isClosing = _closeController.isAnimating ||
              _closeController.status == AnimationStatus.completed;

          if (isClosing) {
            return Transform.scale(
              scale: _closeScaleAnimation.value,
              child: Transform.rotate(
                angle: _closeRotateAnimation.value,
                child: child,
              ),
            );
          }

          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: (1 - _spinAnimation.value) * 6 * math.pi,
              child: child,
            ),
          );
        },
        child: SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildThemeOption(
                emoji: '☀️',
                value: ThemeMode.light,
                angle: -math.pi / 2,
              ),
              _buildThemeOption(
                emoji: '🌙',
                value: ThemeMode.dark,
                angle: math.pi / 6,
              ),
              _buildThemeOption(
                emoji: '📱',
                value: ThemeMode.system,
                angle: 5 * math.pi / 6,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required String emoji,
    required ThemeMode value,
    required double angle,
  }) {
    final theme = Theme.of(context);
    final center = 140.0;
    final radius = 60.0;

    final dx = math.cos(angle) * radius;
    final dy = math.sin(angle) * radius;

    final isSelected = widget.currentTheme == value;

    return Positioned(
      left: center + dx - 45,
      top: center + dy - 45,
      child: GestureDetector(
        onTap: () => _selectTheme(value),
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.5)
                    : theme.colorScheme.shadow.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 40)),
          ),
        ),
      ),
    );
  }
}
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Диалог выбора темы приложения: светлая, тёмная, системная
class ThemeWheelDialog extends StatefulWidget {
  const ThemeWheelDialog({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  final ThemeMode currentTheme;
  final ValueChanged<ThemeMode> onThemeChanged;

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

  bool _isClosing = false;

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
    if (_isClosing) return;
    _isClosing = true;

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
    const center = 140.0;
    const radius = 60.0;
    const bladeSize = 90.0;
    const offset = 45.0;

    final theme = Theme.of(context);
    final dx = math.cos(angle) * radius;
    final dy = math.sin(angle) * radius;

    final isSelected = widget.currentTheme == value;

    return Positioned(
      left: center + dx - offset,
      top: center + dy - offset,
      child: GestureDetector(
        onTap: () => _selectTheme(value),
        child: Container(
          width: bladeSize,
          height: bladeSize,
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
                    ? theme.colorScheme.primary.withValues(alpha: 0.5)
                    : theme.colorScheme.shadow.withValues(alpha: 0.2),
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
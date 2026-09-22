import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:lays_rating/theme/colors.dart';

/// Диалог выбора акцентного цвета приложения
class ColorWheelDialog extends StatefulWidget {
  const ColorWheelDialog({
    super.key,
    required this.currentColor,
    required this.onColorChanged,
  });

  final String currentColor;
  final ValueChanged<String> onColorChanged;

  @override
  State<ColorWheelDialog> createState() => _ColorWheelDialogState();
}

class _ColorWheelDialogState extends State<ColorWheelDialog>
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

  Future<void> _selectColor(String value) async {
    if (_isClosing) return;
    _isClosing = true;

    await _closeController.forward();

    if (mounted) {
      widget.onColorChanged(value);
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
              _buildBlade(
                color: AppColors.pink,
                emoji: '💗',
                value: 'pink',
                angle: -math.pi / 2,
              ),
              _buildBlade(
                color: AppColors.blue,
                emoji: '💙',
                value: 'blue',
                angle: math.pi / 6,
              ),
              _buildBlade(
                color: AppColors.black,
                emoji: '🖤',
                value: 'black',
                angle: 5 * math.pi / 6,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlade({
    required Color color,
    required String emoji,
    required String value,
    required double angle,
  }) {
    const center = 140.0;
    const radius = 60.0;
    const bladeSize = 90.0;
    const offset = 38.0;

    final dx = math.cos(angle) * radius;
    final dy = math.sin(angle) * radius;

    return Positioned(
      left: center + dx - offset,
      top: center + dy - offset,
      child: GestureDetector(
        onTap: () => _selectColor(value),
        child: Container(
          width: bladeSize,
          height: bladeSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 30)),
          ),
        ),
      ),
    );
  }
}
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:lays_rating/models/chip.dart';
import 'package:lays_rating/services/auth_service.dart';

const double _cardSize = 320;
const double _cardRadius = 24;

// Переворачивающаяся карточка чипса:
class ChipFlipCard extends StatefulWidget {
  const ChipFlipCard({
    super.key,
    required this.chip,
  });

  final LaysChip chip;

  @override
  State<ChipFlipCard> createState() => _ChipFlipCardState();
}

class _ChipFlipCardState extends State<ChipFlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_controller.value <= 0.5) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isFront = _animation.value <= 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_animation.value * math.pi),
            child: isFront
                ? Center(child: _buildFront(context))
                : Center(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: _buildBack(context),
                    ),
                  ),
          );
        },
      ),
    );
  }

  /// Лицевая сторона — картинка.
  Widget _buildFront(BuildContext context) {
    final chip = widget.chip;
    final colorScheme = Theme.of(context).colorScheme;

    return Hero(
      tag: chip.id,
      child: Container(
        height: _cardSize,
        width: _cardSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_cardRadius),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.2),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                '${AuthService.baseUrl}/chips/images/${chip.imagePath}',
                width: _cardSize,
                height: _cardSize,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    width: _cardSize,
                    height: _cardSize,
                    color: colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: _cardSize,
                    height: _cardSize,
                    color: colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
            _buildHint('Детали'),
          ],
        ),
      ),
    );
  }

  /// Обратная сторона — информация.
  Widget _buildBack(BuildContext context) {
    final chip = widget.chip;
    final theme = Theme.of(context);

    return Container(
      height: _cardSize,
      width: _cardSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_cardRadius),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.2),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 36,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.category_rounded,
                    label: 'Категория',
                    value: chip.category.title,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Год выпуска',
                    value: chip.releaseYear.toString(),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.public_rounded,
                    label: 'Страна',
                    value: chip.country,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.collections_bookmark_rounded,
                    label: 'Коллекция',
                    value: chip.collection,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.shopping_cart_rounded,
                    label: 'Наличие',
                    value: chip.available ? 'В продаже' : 'Снят с продажи',
                  ),
                ],
              ),
            ),
          ),
          _buildHint('Назад'),
        ],
      ),
    );
  }

  /// Подсказка в правом нижнем углу.
  Widget _buildHint(String label) {
    return Positioned(
      bottom: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black.withOpacity(0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.touch_app_rounded,
              color: Colors.white,
              size: 12,
            ),
            const SizedBox(width: 3),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Строка «иконка + подпись + значение» на обратной стороне.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: theme.colorScheme.surface.withOpacity(0.7),
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
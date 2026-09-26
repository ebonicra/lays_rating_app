import 'package:flutter/material.dart';

import 'package:lays_rating/models/chip_type.dart';

class FilterCard extends StatefulWidget {
  const FilterCard({
    super.key,
    required this.type,
    required this.selected,
    required this.onTap,
    this.total,
    this.tried,
  });

  final ChipType type;
  final bool selected;
  final VoidCallback onTap;
  final int? total;
  final int? tried;

  @override
  State<FilterCard> createState() => _FilterCardState();
}

class _FilterCardState extends State<FilterCard> {
  bool _pressed = false;
  bool _showStats = false;

  bool get _hasStats => widget.total != null && widget.tried != null;

  void _handleTap() {
    // Если открыта статистика — тап её закрывает, а не выделяет категорию
    if (_showStats) {
      setState(() => _showStats = false);
      return;
    }
    widget.onTap();
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    if (!_hasStats) return;
    setState(() => _showStats = true);
  }

  void _handleLongPressEnd() {
    if (!_showStats) return;
    setState(() => _showStats = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedScale(
      scale: _pressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: _handleTap,
        onLongPressStart: _handleLongPressStart,
        onLongPressEnd: (_) => _handleLongPressEnd(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: widget.selected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: widget.selected ? 12 : 8,
                spreadRadius: widget.selected ? 1 : 0,
                offset: const Offset(0, 4),
                color: Colors.black.withOpacity(
                  widget.selected ? 0.18 : 0.10,
                ),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _showStats
                ? _buildStats(context)
                : _buildDefault(context),
          ),
        ),
      ),
    );
  }

  Widget _buildDefault(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey('default'),
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(
          widget.type.icon,
          size: 55,
          color: widget.selected
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
        ),
        Text(
          widget.type.title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          widget.type.description,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
            height: 1.2,
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: widget.selected
              ? Text(
                  '👀 Отслеживаю',
                  key: const ValueKey('selected'),
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                )
              : Text(
                  '➖ Не интересно',
                  key: const ValueKey('unselected'),
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final total = widget.total ?? 0;
    final tried = widget.tried ?? 0;
    final remaining = (total - tried).clamp(0, total);
    final progress = total > 0 ? tried / total : 0.0;

    return Column(
      key: const ValueKey('stats'),
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(
          widget.type.icon,
          size: 40,
          color: colorScheme.primary,
        ),
        Text(
          widget.type.title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              // Дорожка видна всегда
              backgroundColor: widget.selected
                  ? colorScheme.primary.withOpacity(0.15)
                  : colorScheme.onSurface.withOpacity(0.10),
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _StatCell(
                value: '$total',
                label: 'всего',
                color: colorScheme.primary,
              ),
            ),
            Expanded(
              child: _StatCell(
                value: '$tried',
                label: 'пробовал',
                color: Colors.green,
              ),
            ),
            Expanded(
              child: _StatCell(
                value: '$remaining',
                label: 'осталось',
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
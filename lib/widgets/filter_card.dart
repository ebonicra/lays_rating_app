import 'package:flutter/material.dart';
import '../models/chip_category.dart';

class FilterCard extends StatefulWidget {
  final ChipCategory category;
  final bool selected;
  final VoidCallback onTap;

  const FilterCard({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  State<FilterCard> createState() => _FilterCardState();
}

class _FilterCardState extends State<FilterCard> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedScale(
      scale: pressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTapDown: (_) => setState(() => pressed = true),
        onTapUp: (_) {
          setState(() => pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => pressed = false),

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: widget.selected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
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

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Иконка
              Icon(
                widget.category.icon,
                size: 50,
                color: widget.selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 6),

              // Название
              Text(
                widget.category.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),

              // Описание — компактно
              Text(
                widget.category.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),

              // Статус
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: widget.selected
                    ? Text(
                        "👀 Отслеживаю",
                        key: const ValueKey("selected"),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      )
                    : Text(
                        "➖ Не интересно",
                        key: const ValueKey("unselected"),
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
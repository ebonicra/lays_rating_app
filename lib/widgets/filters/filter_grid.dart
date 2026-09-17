import 'package:flutter/material.dart';

import 'package:lays_rating/models/chip_type.dart';
import 'package:lays_rating/widgets/filters/filter_card.dart';

/// Сетка карточек фильтров: раскладывает в 2 колонки,
class FilterGrid extends StatelessWidget {
  const FilterGrid({
    super.key,
    required this.types,
    required this.selected,
    required this.onToggle,
  });

  final List<ChipType> types;
  final Set<String> selected;
  final ValueChanged<ChipType> onToggle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 2 колонки, 3 строки — рассчитываем aspect ratio под доступное место.
        const crossAxisCount = 2;
        const rowCount = 3;
        const spacing = 10.0;

        final cardWidth =
            (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
                crossAxisCount;
        final cardHeight =
            (constraints.maxHeight - spacing * (rowCount - 1)) / rowCount;
        final aspectRatio = cardWidth / cardHeight;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: aspectRatio,
          ),
          itemCount: types.length,
          itemBuilder: (context, index) {
            final type = types[index];
            final isSelected = selected.contains(type.value);

            return FilterCard(
              type: type,
              selected: isSelected,
              onTap: () => onToggle(type),
            );
          },
        );
      },
    );
  }
}
import 'package:flutter/material.dart';

import 'package:lays_rating/models/chip_type.dart';
import 'package:lays_rating/widgets/filters/filter_card.dart';

/// Сетка карточек фильтров
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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final crossAxisCount = isLandscape ? 3 : 2;

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 1),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.95,
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
  }
}
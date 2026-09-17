import 'package:flutter/material.dart';

// Меню сортировки списка чипсов
class ChipsSortMenu extends StatelessWidget {
  const ChipsSortMenu({
    super.key,
    required this.sortField,
    required this.sortAscending,
    required this.onSelected,
  });

  final String sortField;
  final bool sortAscending;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.swap_vert_rounded),
      iconSize: 26,
      tooltip: 'Сортировка',
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: onSelected,
      itemBuilder: (context) => [
        _buildItem(context, 'rating', 'По рейтингу', Icons.star_rounded),
        _buildItem(context, 'name', 'По названию', Icons.sort_by_alpha_rounded),
        _buildItem(context, 'date', 'По дате', Icons.calendar_today_rounded),
      ],
    );
  }

  PopupMenuItem<String> _buildItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final isActive = sortField == value;
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuItem<String>(
      value: value,
      height: 40,
      child: SizedBox(
        width: 140,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isActive)
              Icon(
                sortAscending
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
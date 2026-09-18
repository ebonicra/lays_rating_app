import 'package:flutter/material.dart';

import 'compact_filter_card.dart';

// Группа компактных фильтров-флагов («Только Россия», «В продаже»)
class CompactFilterGrid extends StatelessWidget {
  const CompactFilterGrid({
    super.key,
    required this.russiaOnly,
    required this.availableOnly,
    required this.onRussiaOnlyTap,
    required this.onAvailableOnlyTap,
  });

  final bool russiaOnly;
  final bool availableOnly;
  final VoidCallback onRussiaOnlyTap;
  final VoidCallback onAvailableOnlyTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CompactFilterCard(
            icon: Icons.public_rounded,
            label: 'Только Россия',
            isSelected: russiaOnly,
            onTap: onRussiaOnlyTap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CompactFilterCard(
            icon: Icons.shopping_cart_rounded,
            label: 'В продаже',
            isSelected: availableOnly,
            onTap: onAvailableOnlyTap,
          ),
        ),
      ],
    );
  }
}
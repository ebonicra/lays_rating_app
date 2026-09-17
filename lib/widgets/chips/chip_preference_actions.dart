import 'package:flutter/material.dart';

import 'package:lays_rating/widgets/common/mini_action_button.dart';

// Пара кнопок-действий над предпочтением чипса «Любимчик» и «Пробовал».
class ChipPreferenceActions extends StatelessWidget {
  const ChipPreferenceActions({
    super.key,
    required this.isFavorite,
    required this.isTried,
    required this.onFavoriteChanged,
    required this.onTriedChanged,
  });

  final bool isFavorite;
  final bool isTried;
  final VoidCallback onFavoriteChanged;
  final VoidCallback onTriedChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MiniActionButton(
          icon: Icons.favorite_outline_rounded,
          label: 'Любимчик',
          active: isFavorite,
          onTap: onFavoriteChanged,
        ),
        const SizedBox(height: 8),
        MiniActionButton(
          icon: Icons.fastfood_rounded,
          label: 'Пробовал',
          active: isTried,
          onTap: onTriedChanged,
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';

import 'package:lays_rating/models/news_item.dart';

/// Содержимое новости «игровой рекорд».
class GameRecordContent extends StatelessWidget {
  const GameRecordContent({
    super.key,
    required this.item,
  });

  final NewsItem item;

  @override
  Widget build(BuildContext context) {
    final score = item.extraData?['score'] ?? 0;

    return Row(
      children: [
        const Icon(Icons.sports_esports, size: 32, color: Colors.purple),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '${item.user?.displayName ?? 'Кто-то'} набрал $score очков в игре! 🎮',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
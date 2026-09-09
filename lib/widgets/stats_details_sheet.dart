import 'package:flutter/material.dart';
import 'package:lays_rating/models/stat_chip.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/services/stats_service.dart';

/// Универсальный bottom sheet для списка чипсов (любимчики, пробовал, оценки)
class ChipsDetailSheet extends StatelessWidget {
  final String title;
  final IconData icon;
  final int userId;
  final ChipsListType type;

  const ChipsDetailSheet({
    super.key,
    required this.title,
    required this.icon,
    required this.userId,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: FutureBuilder<List<StatChip>>(
        future: _fetchChips(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Не удалось загрузить'));
          }

          final chips = snapshot.data!;

          if (chips.isEmpty) {
            return Center(
              child: Text(
                _getEmptyText(),
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: chips.length,
                    itemBuilder: (context, index) {
                      final chip = chips[index];
                      return _ChipTile(
                        chip: chip,
                        type: type, // ← передаём тип
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<List<StatChip>> _fetchChips() {
    switch (type) {
      case ChipsListType.favorites:
        return StatsService.getFavoriteChips(userId);
      case ChipsListType.tried:
        return StatsService.getTriedChips(userId);
      case ChipsListType.ratings:
        return StatsService.getRatings(userId);
      case ChipsListType.comments:
        return StatsService.getCommentedChips(userId); // ← но возвращает CommentedChip
    }
  }

  String _getEmptyText() {
    switch (type) {
      case ChipsListType.favorites:
        return 'Пока нет любимчиков';
      case ChipsListType.tried:
        return 'Пока ничего не пробовал';
      case ChipsListType.ratings:
        return 'Пока нет оценок';
      case ChipsListType.comments:
        return 'Пока нет комментариев';
    }
  }
}

enum ChipsListType {
  favorites,
  tried,
  ratings,
  comments
}

class _ChipTile extends StatelessWidget {
  final StatChip chip;
  final ChipsListType type;

  const _ChipTile({
    required this.chip,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          '${AuthService.baseUrl}/chips/images/${chip.imagePath}',
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              width: 70,
              height: 70,
              color: Colors.grey.shade200,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 70,
              height: 70,
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.grey, size: 20),
              ),
            );
          },
        ),
      ),
      title: Text(chip.name),
      subtitle: Text(
        _getSubtitle(), // ← гибкий subtitle
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        // TODO: открыть страницу чипсов
      },
    );
  }

  /// Возвращает подпись в зависимости от типа списка
  String _getSubtitle() {
    switch (type) {
      case ChipsListType.favorites:
        if (chip.favoriteCount == 1) {
          return 'Ты первый, кто оценил!';
        }
        return '❤️ ${chip.favoriteCount} оценили';
      
      case ChipsListType.tried:
        if (chip.triedCount == 1) {
          return 'Ты первый, кто попробовал!';
        }
        return '✅ ${chip.triedCount} попробовали';

      case ChipsListType.ratings:
        final myRating = chip.myRating;
        final avgRating = chip.averageRating;
        final count = chip.ratingCount;
        
        if (myRating != null) {
          return '⭐ Моя: $myRating  |  Средняя: $avgRating ($count)';
        } else {
          return '⭐ Средняя: $avgRating($count)';
        }

      case ChipsListType.comments:
        return '💬 ${chip.myCommentsCount} | 👍 ${chip.reactionsCount}';
    }
  }
}
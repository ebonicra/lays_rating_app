import 'package:flutter/material.dart';

import 'package:lays_rating/models/stat_chip.dart';
import 'package:lays_rating/widgets/chips/chip_details_page.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/services/stats_service.dart';


class ChipsSheet extends StatefulWidget {
  const ChipsSheet({
    super.key,
    required this.title,
    required this.icon,
    required this.userId,
    required this.type,
  });

  final String title;
  final IconData icon;
  final int userId;
  final ChipsListType type;

  @override
  State<ChipsSheet> createState() => _ChipsSheetState();
}

class _ChipsSheetState extends State<ChipsSheet> {
  late final Future<List<StatChip>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchChips();
  }

  Future<List<StatChip>> _fetchChips() {
    switch (widget.type) {
      case ChipsListType.favorites:
        return StatsService.getFavoriteChips(widget.userId);
      case ChipsListType.tried:
        return StatsService.getTriedChips(widget.userId);
      case ChipsListType.ratings:
        return StatsService.getRatings(widget.userId);
      case ChipsListType.comments:
        return StatsService.getCommentedChips(widget.userId);
    }
  }

  String _getEmptyText() {
    switch (widget.type) {
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: FutureBuilder<List<StatChip>>(
        future: _future,
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
                    Icon(
                      widget.icon,
                      size: 28,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.title,
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
                      return _ChipTile(
                        chip: chips[index],
                        type: widget.type,
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
}

enum ChipsListType {
  favorites,
  tried,
  ratings,
  comments,
}

class _ChipTile extends StatelessWidget {
  const _ChipTile({
    required this.chip,
    required this.type,
  });

  final StatChip chip;
  final ChipsListType type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          '${AuthService.baseUrl}/chips/images/${chip.imagePath}',
          width: 60,
          height: 70,
          cacheWidth: 120,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              width: 60,
              height: 70,
              color: colorScheme.surfaceContainerHighest,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 60,
              height: 70,
              color: colorScheme.surfaceContainerHighest,
              child: Center(
                child: Icon(
                  Icons.broken_image,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            );
          },
        ),
      ),
      title: Text(chip.name),
      subtitle: Text(
        _getSubtitle(),
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChipDetailsPage(chipId: chip.id),
          ),
        );
      },
    );
  }

  String _getSubtitle() {
    switch (type) {
      case ChipsListType.favorites:
        if (chip.favoriteCount == 1) {
          return 'Первый, кто оценил!';
        }
        return '❤️ ${chip.favoriteCount} оценили';

      case ChipsListType.tried:
        if (chip.triedCount == 1) {
          return 'Первый, кто попробовал!';
        }
        return '✅ ${chip.triedCount} попробовали';

      case ChipsListType.ratings:
        final myRating = chip.myRating;
        final avgRating = chip.averageRating;
        final count = chip.ratingCount;
        return '⭐ Оценка: $myRating  |  Средняя: $avgRating ($count)';

      case ChipsListType.comments:
        return '${chip.myCommentsCount} ${_pluralizeComments(chip.myCommentsCount)}  |  ${chip.reactionsCount} ${_pluralizeReactions(chip.reactionsCount)}';
    }
  }

  String _pluralizeComments(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'комментарий ';
    if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return 'комментария ';
    }
    return 'комментариев';
  }

  String _pluralizeReactions(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'реакция';
    if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return 'реакции';
    }
    return 'реакций';
  }
}
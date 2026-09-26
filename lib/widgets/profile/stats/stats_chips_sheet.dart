import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:lays_rating/models/stats/stats_chip.dart';
import 'package:lays_rating/widgets/chips/chip_details_page.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/services/stats_service.dart';
import 'package:lays_rating/utils/pluralize.dart';

import 'package:lays_rating/models/stats/stats_chips_type.dart';


// Bottom sheet со списком чипсов по типу статистики
class StatsChipsSheet extends StatefulWidget {
  const StatsChipsSheet({
    super.key,
    required this.title,
    required this.icon,
    required this.userId,
    required this.type,
  });

  final String title;
  final IconData icon;
  final int userId;
  final StatsChipsType type;

  @override
  State<StatsChipsSheet> createState() => _StatsChipsSheetState();
}

class _StatsChipsSheetState extends State<StatsChipsSheet> {
  late final Future<List<StatsChip>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchChips();
  }

  Future<List<StatsChip>> _fetchChips() {
    switch (widget.type) {
      case StatsChipsType.favorites:
        return StatsService.getFavoriteChips(widget.userId);
      case StatsChipsType.tried:
        return StatsService.getTriedChips(widget.userId);
      case StatsChipsType.ratings:
        return StatsService.getRatings(widget.userId);
      case StatsChipsType.comments:
        return StatsService.getCommentedChips(widget.userId);
    }
  }

  String _getEmptyText() {
    switch (widget.type) {
      case StatsChipsType.favorites:
        return 'Пока нет любимчиков';
      case StatsChipsType.tried:
        return 'Пока ничего не пробовал';
      case StatsChipsType.ratings:
        return 'Пока нет оценок';
      case StatsChipsType.comments:
        return 'Пока нет комментариев';
    }
  }
  

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: FutureBuilder<List<StatsChip>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Не удалось загрузить'));
          }

          final chips = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon, size: 28, color: colorScheme.primary),
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
                  child: chips.isEmpty
                      ? Center(
                          child: Text(
                            _getEmptyText(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
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



class _ChipTile extends StatelessWidget {
  const _ChipTile({
    required this.chip,
    required this.type,
  });

  final StatsChip chip;
  final StatsChipsType type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: '${AuthService.baseUrl}/chips/images/${chip.imagePath}',
          width: 60,
          height: 70,
          fit: BoxFit.cover,
          memCacheWidth: (60 * MediaQuery.devicePixelRatioOf(context)).round(),
          placeholder: (context, url) => Container(
            width: 60,
            height: 70,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (context, url, error) => Container(
            width: 60,
            height: 70,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Center(child: Icon(Icons.broken_image)),
          ),
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
      case StatsChipsType.favorites:
        if (chip.favoriteCount == 1) {
          return 'Первый, кто оценил!';
        }
        return '❤️ ${chip.favoriteCount} оценили';

      case StatsChipsType.tried:
        if (chip.triedCount == 1) {
          return 'Первый, кто попробовал!';
        }
        return '✅ ${chip.triedCount} попробовали';

      case StatsChipsType.ratings:
        final myRating = chip.myRating;
        final avgRating = chip.averageRating;
        final count = chip.ratingCount;
        return '⭐ Оценка: $myRating  |  Средняя: $avgRating ($count)';

      case StatsChipsType.comments:
        final commentsWord = pluralize(
          chip.myCommentsCount,
          one: 'комментарий',
          few: 'комментария',
          many: 'комментариев',
        );
        final reactionsWord = pluralize(
          chip.reactionsCount,
          one: 'реакция',
          few: 'реакции',
          many: 'реакций',
        );
        return '${chip.myCommentsCount} $commentsWord  |  '
            '${chip.reactionsCount} $reactionsWord';
    }
  }
}
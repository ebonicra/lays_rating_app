import 'package:flutter/material.dart';

import 'package:lays_rating/widgets/profile/stats/profile_stats_sheets.dart';
import 'package:lays_rating/widgets/profile/stats/stats_carousel.dart';

import 'package:lays_rating/models/stats/stats_user.dart';
import 'package:lays_rating/models/stats/stats_square.dart';


class ProfileStatsCarousel extends StatelessWidget {
  const ProfileStatsCarousel({
    super.key,
    required this.stats,
    required this.userId,
  });

  final StatsUser? stats;
  final int userId;

  static const double _carouselHeight = 100;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _carouselHeight,
      child: StatsCarousel(
        items: [
          StatsSquare(
            icon: Icons.star_rounded,
            label: 'Оценок',
            value: '${stats?.ratingsCount ?? 0}',
            onTap: () async {
              await ProfileStatsSheets.showRatings(context, userId);
            },
          ),
          StatsSquare(
            icon: Icons.trending_up_rounded,
            label: 'Средняя',
            value: (stats?.averageRating ?? 0).toStringAsFixed(1),
            onTap: () => ProfileStatsSheets.showFriendsAverageRating(context, userId),
          ),
          StatsSquare(
            icon: Icons.favorite_rounded,
            label: 'Любимчиков',
            value: '${stats?.favoritesCount ?? 0}',
            onTap: () => ProfileStatsSheets.showFavorites(context, userId),
          ),
          StatsSquare(
            icon: Icons.check_circle_rounded,
            label: 'Пробовал',
            value: '${stats?.triedCount ?? 0}',
            onTap: () => ProfileStatsSheets.showTried(context, userId),
          ),
          StatsSquare(
            icon: Icons.chat_bubble_rounded,
            label: 'Комментариев',
            value: '${stats?.commentsCount ?? 0}',
            onTap: () => ProfileStatsSheets.showComments(context, userId),
          ),
          StatsSquare(
            icon: Icons.group_rounded,
            label: 'Подписчиков',
            value: '${stats?.followersCount ?? 0}',
            onTap: () => ProfileStatsSheets.showFollowers(context, userId),
          ),
          StatsSquare(
            icon: Icons.person_add_alt_rounded,
            label: 'Подписок',
            value: '${stats?.followingCount ?? 0}',
            onTap: () => ProfileStatsSheets.showFollowing(context, userId),
          ),
        ],
      ),
    );
  }
}
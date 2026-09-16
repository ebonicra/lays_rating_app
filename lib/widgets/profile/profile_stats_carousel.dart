import 'package:flutter/material.dart';

import 'package:lays_rating/models/user_stats.dart';
import 'package:lays_rating/models/stat_square_data.dart';

import 'package:lays_rating/widgets/profile/profile_sheets.dart';
import 'package:lays_rating/widgets/stats/stats_carousel.dart';

class ProfileStatsCarousel extends StatelessWidget {
  const ProfileStatsCarousel({
    super.key,
    required this.stats,
    required this.userId,
  });

  final UserStats? stats;
  final int userId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: InfiniteStatsCarousel(
        items: [
          StatSquareData(
            icon: Icons.star_rounded,
            label: 'Оценок',
            value: '${stats?.ratingsCount ?? 0}',
            onTap: () => ProfileSheets.showRatings(context, userId),
          ),
          StatSquareData(
            icon: Icons.favorite_rounded,
            label: 'Любимчиков',
            value: '${stats?.favoritesCount ?? 0}',
            onTap: () => ProfileSheets.showFavorites(context, userId),
          ),
          StatSquareData(
            icon: Icons.check_circle_rounded,
            label: 'Пробовал',
            value: '${stats?.triedCount ?? 0}',
            onTap: () => ProfileSheets.showTried(context, userId),
          ),
          StatSquareData(
            icon: Icons.chat_bubble_rounded,
            label: 'Комментариев',
            value: '${stats?.commentsCount ?? 0}',
            onTap: () => ProfileSheets.showComments(context, userId),
          ),
          StatSquareData(
            icon: Icons.trending_up_rounded,
            label: 'Средняя',
            value: '${stats?.averageRating ?? 0.0}',
            onTap: () => ProfileSheets.showFriendsAverageRating(context, userId),
          ),
          StatSquareData(
            icon: Icons.group_rounded,
            label: 'Подписчиков',
            value: '${stats?.followersCount ?? 0}',
            onTap: () => ProfileSheets.showFollowers(context, userId),
          ),
          StatSquareData(
            icon: Icons.person_add_alt_rounded,
            label: 'Подписок',
            value: '${stats?.followingCount ?? 0}',
            onTap: () => ProfileSheets.showFollowing(context, userId),
          ),
        ],
      ),
    );
  }
}
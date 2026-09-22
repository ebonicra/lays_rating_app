import 'package:flutter/material.dart';

import 'package:lays_rating/widgets/profile/stats/stats_chips_sheet.dart';
import 'package:lays_rating/widgets/profile/stats/stats_follows_sheet.dart';
import 'package:lays_rating/models/stats/stats_chips_type.dart';
import 'package:lays_rating/models/stats/stats_follows_type.dart';

// Открывает bottom sheet'ы со статистикой профиля
class ProfileStatsSheets {
  ProfileStatsSheets._();

  static Future<void> showRatings(BuildContext context, int userId) => _chips_sheet(
        context: context,
        title: 'Оценки',
        icon: Icons.star_rounded,
        userId: userId,
        type: StatsChipsType.ratings,
      );

  static Future<void> showFriendsAverageRating(BuildContext context, int userId) => _follows_sheet(
      context: context,
      title: 'Средняя оценка друзей',
      icon: Icons.trending_up_rounded,
      userId: userId,
      type: StatsFollowsType.friendsAverageRating,
    );

  static Future<void> showFavorites(BuildContext context, int userId) => _chips_sheet(
        context: context,
        title: 'Любимчики',
        icon: Icons.favorite_rounded,
        userId: userId,
        type: StatsChipsType.favorites,
      );

  static Future<void> showTried(BuildContext context, int userId) => _chips_sheet(
        context: context,
        title: 'Пробовал',
        icon: Icons.check_circle_rounded,
        userId: userId,
        type: StatsChipsType.tried,
      );

  static Future<void> showComments(BuildContext context, int userId) => _chips_sheet(
        context: context,
        title: 'Комментарии',
        icon: Icons.chat_bubble_rounded,
        userId: userId,
        type: StatsChipsType.comments,
      );

  static Future<void> showFollowing(BuildContext context, int userId) => _follows_sheet(
        context: context,
        title: 'Подписки',
        icon: Icons.person_add_alt_rounded,
        userId: userId,
        type: StatsFollowsType.following,
      );

  static Future<void> showFollowers(BuildContext context, int userId) => _follows_sheet(
        context: context,
        title: 'Подписчики',
        icon: Icons.group_rounded,
        userId: userId,
        type: StatsFollowsType.followers,
      );



  static Future<void> _chips_sheet({
    required BuildContext context,
    required String title,
    required IconData icon,
    required int userId,
    required StatsChipsType type,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatsChipsSheet(
        title: title,
        icon: icon,
        userId: userId,
        type: type,
      ),
    );
  }

  static Future<void> _follows_sheet({
    required BuildContext context,
    required String title,
    required IconData icon,
    required int userId,
    required StatsFollowsType type,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatsFollowsSheet(
        title: title,
        icon: icon,
        userId: userId,
        type: type,
      ),
    );
  }
}
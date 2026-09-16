import 'package:flutter/material.dart';

import 'package:lays_rating/widgets/stats/chips_sheet.dart';
import 'package:lays_rating/widgets/stats/follows_sheet.dart';


class ProfileSheets {
  ProfileSheets._();

  static Future<void> showRatings(BuildContext context, int userId) => _chips(
        context: context,
        title: 'Оценки',
        icon: Icons.star_rounded,
        userId: userId,
        type: ChipsListType.ratings,
      );

  static Future<void> showFavorites(BuildContext context, int userId) => _chips(
        context: context,
        title: 'Любимчики',
        icon: Icons.favorite_rounded,
        userId: userId,
        type: ChipsListType.favorites,
      );

  static Future<void> showTried(BuildContext context, int userId) => _chips(
        context: context,
        title: 'Пробовал',
        icon: Icons.check_circle_rounded,
        userId: userId,
        type: ChipsListType.tried,
      );

  static Future<void> showComments(BuildContext context, int userId) => _chips(
        context: context,
        title: 'Комментарии',
        icon: Icons.chat_bubble_rounded,
        userId: userId,
        type: ChipsListType.comments,
      );

  static Future<void> showFollowing(BuildContext context, int userId) => _follows(
        context: context,
        title: 'Подписки',
        icon: Icons.person_add_alt_rounded,
        userId: userId,
        type: FollowsSheetType.following,
      );

  static Future<void> showFollowers(BuildContext context, int userId) => _follows(
        context: context,
        title: 'Подписчики',
        icon: Icons.group_rounded,
        userId: userId,
        type: FollowsSheetType.followers,
      );

  static Future<void> showFriendsAverageRating(BuildContext context, int userId) => _follows(
        context: context,
        title: 'Средняя оценка друзей',
        icon: Icons.trending_up_rounded,
        userId: userId,
        type: FollowsSheetType.friendsAverageRating,
      );



  static Future<void> _chips({
    required BuildContext context,
    required String title,
    required IconData icon,
    required int userId,
    required ChipsListType type,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ChipsSheet(
        title: title,
        icon: icon,
        userId: userId,
        type: type,
      ),
    );
  }

  static Future<void> _follows({
    required BuildContext context,
    required String title,
    required IconData icon,
    required int userId,
    required FollowsSheetType type,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FollowsSheet(
        title: title,
        icon: icon,
        userId: userId,
        type: type,
      ),
    );
  }
}
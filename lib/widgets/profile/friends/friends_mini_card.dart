import 'package:flutter/material.dart';

import 'package:lays_rating/models/user_brief.dart';
import 'package:lays_rating/widgets/common/user_action_button.dart';
import 'package:lays_rating/widgets/common/user_list_tile.dart';

/// Карточка пользователя в списке с кнопкой подписки.
class FriendsMiniCard extends StatelessWidget {
  const FriendsMiniCard({
    super.key,
    required this.user,
    required this.isFollowing,
    required this.onToggleFollow,
    this.onReturn,
  });

  final UserBrief user;
  final bool isFollowing;
  final VoidCallback onToggleFollow;
  final VoidCallback? onReturn;

  @override
  Widget build(BuildContext context) {
    return UserListTile(
      userId: user.id,
      displayName: user.displayName,
      username: user.username,
      avatarUrl: user.avatarUrl,
      avatarRadius: 16,
      trailing: UserActionButton(
        label: isFollowing ? 'Отписаться' : 'Подписаться',
        active: isFollowing,
        onTap: onToggleFollow,
      ),
      onReturn: onReturn,
    );
  }
}
import 'package:flutter/material.dart';

import 'package:lays_rating/pages/profile/public_profile_page.dart';

import 'user_avatar.dart';

/// Карточка пользователя в списке: аватар, имя, @username и слот справа
class UserListTile extends StatelessWidget {
  const UserListTile({
    super.key,
    required this.userId,
    required this.displayName,
    required this.username,
    this.avatarUrl,
    this.trailing,
    this.avatarRadius = 20,
    this.onReturn,
  });

  final int userId;
  final String displayName;
  final String username;
  final String? avatarUrl;
  final Widget? trailing;
  final double avatarRadius;
  final VoidCallback? onReturn;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: UserAvatar(
          displayName: displayName,
          avatarUrl: avatarUrl,
          radius: avatarRadius,
        ),
        horizontalTitleGap: 10,
        title: Text(
          displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('@$username'),
        trailing: trailing,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PublicProfilePage(userId: userId),
            ),
          ).then((_) => onReturn?.call());
        },
      ),
    );
  }
}
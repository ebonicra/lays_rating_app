import 'package:flutter/material.dart';

import 'package:lays_rating/widgets/profile/friends/friends_page.dart';

/// Карточка-переход на страницу друзей и приятелей пользователя.
class ProfileFriendsCard extends StatelessWidget {
  const ProfileFriendsCard({
    super.key,
    required this.userId,
  });

  final int userId;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.group_rounded),
        title: const Text('Друзья и приятели'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FriendsPage(userId: userId),
            ),
          );
        },
      ),
    );
  }
}
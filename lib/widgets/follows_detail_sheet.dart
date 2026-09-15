import 'package:flutter/material.dart';
import 'package:lays_rating/models/follow_user.dart';
import 'package:lays_rating/services/follow_service.dart';
import 'package:lays_rating/services/stats_service.dart';
import 'package:lays_rating/services/auth_service.dart';

import 'package:lays_rating/pages/public_profile_page.dart';

class FollowsDetailSheet extends StatelessWidget {
  final String title;
  final IconData icon;
  final int userId;
  final FollowsSheetType type; // ← тип: подписки, подписчики, средняя оценка

  const FollowsDetailSheet({
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
      child: FutureBuilder<List<FollowUser>>(
        future: _fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Не удалось загрузить'));
          }

          final users = snapshot.data!;

          if (users.isEmpty) {
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
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return _buildTile(context, user);
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

  Future<List<FollowUser>> _fetchUsers() {
    switch (type) {
      case FollowsSheetType.following:
        return FollowService.getFollowing(userId: userId);
      case FollowsSheetType.followers:
        return FollowService.getFollowers(userId: userId);
      case FollowsSheetType.friendsAverageRating:
        return StatsService.getFriendsAverageRating(userId);
    }
  }

  String _getEmptyText() {
    switch (type) {
      case FollowsSheetType.following:
        return 'Нет подписок';
      case FollowsSheetType.followers:
        return 'Нет подписчиков';
      case FollowsSheetType.friendsAverageRating:
        return 'Нет подписок — подпишись на друзей!';
    }
  }

  Widget _buildTile(BuildContext context, FollowUser user) {
    switch (type) {
      case FollowsSheetType.friendsAverageRating:
        // Для средней оценки — показываем рейтинг справа
        return ListTile(
          leading: _buildAvatar(user),
          title: Text(
            user.displayName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('@${user.username}'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (user.averageRating ?? 0) >= 4.0
                  ? Colors.green.withOpacity(0.1)
                  : Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  (user.averageRating ?? 0).toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PublicProfilePage(userId: user.id),
              ),
            );
          },
        );

      case FollowsSheetType.following:
      case FollowsSheetType.followers:
        // Для подписок/подписчиков — без рейтинга
        return ListTile(
          leading: _buildAvatar(user),
          title: Text(
            user.displayName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('@${user.username}'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PublicProfilePage(userId: user.id),
              ),
            );
          },
        );
    }
  }

  Widget _buildAvatar(FollowUser user) {
    return CircleAvatar(
      radius: 22,
      backgroundImage: user.avatarUrl != null
          ? NetworkImage('${AuthService.baseUrl}${user.avatarUrl}')
          : null,
      child: user.avatarUrl == null
          ? Text(
              user.displayName.substring(0, 1).toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
          : null,
    );
  }
}

enum FollowsSheetType {
  following,
  followers,
  friendsAverageRating,
}
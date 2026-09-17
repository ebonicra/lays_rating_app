import 'package:flutter/material.dart';

import 'package:lays_rating/models/follow_user.dart';
import 'package:lays_rating/pages/profile/public_profile_page.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/services/follow_service.dart';
import 'package:lays_rating/services/stats_service.dart';
import 'package:lays_rating/utils/initials.dart';

class FollowsSheet extends StatefulWidget {
  const FollowsSheet({
    super.key,
    required this.title,
    required this.icon,
    required this.userId,
    required this.type,
  });

  final String title;
  final IconData icon;
  final int userId;
  final FollowsSheetType type;

  @override
  State<FollowsSheet> createState() => _FollowsSheetState();
}

class _FollowsSheetState extends State<FollowsSheet> {
  late final Future<List<FollowUser>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchUsers();
  }

  Future<List<FollowUser>> _fetchUsers() {
    switch (widget.type) {
      case FollowsSheetType.following:
        return FollowService.getFollowing(userId: widget.userId);
      case FollowsSheetType.followers:
        return FollowService.getFollowers(userId: widget.userId);
      case FollowsSheetType.friendsAverageRating:
        return StatsService.getFriendsAverageRating(widget.userId);
    }
  }

  String _getEmptyText() {
    switch (widget.type) {
      case FollowsSheetType.following:
        return 'Нет подписок';
      case FollowsSheetType.followers:
        return 'Нет подписчиков';
      case FollowsSheetType.friendsAverageRating:
        return 'Нет подписок — подпишись на друзей!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: FutureBuilder<List<FollowUser>>(
        future: _future,
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
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return _FollowTile(
                        user: users[index],
                        showRating: widget.type ==
                            FollowsSheetType.friendsAverageRating,
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

enum FollowsSheetType {
  following,
  followers,
  friendsAverageRating,
}

class _FollowTile extends StatelessWidget {
  const _FollowTile({
    required this.user,
    required this.showRating,
  });

  final FollowUser user;
  final bool showRating;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildAvatar(context),
      title: Text(
        user.displayName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('@${user.username}'),
      trailing: showRating ? _buildRatingBadge(context) : null,
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

  Widget _buildAvatar(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundImage: user.avatarUrl != null
          ? NetworkImage('${AuthService.baseUrl}${user.avatarUrl}')
          : null,
      child: user.avatarUrl == null
          ? Text(
              initialOf(user.displayName),
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
          : null,
    );
  }

  Widget _buildRatingBadge(BuildContext context) {
    final rating = user.averageRating ?? 0;
    final isHigh = rating >= 4.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isHigh
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
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
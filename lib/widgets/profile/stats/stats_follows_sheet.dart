import 'package:flutter/material.dart';

import 'package:lays_rating/models/stats/stats_follow.dart';
import 'package:lays_rating/models/stats/stats_follows_type.dart';
import 'package:lays_rating/pages/profile/public_profile_page.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/services/follow_service.dart';
import 'package:lays_rating/services/stats_service.dart';
import 'package:lays_rating/utils/initials.dart';
import 'package:lays_rating/widgets/common/rating_badge.dart';


// Bottom sheet со списком пользователей по типу статистики
class StatsFollowsSheet extends StatefulWidget {
  const StatsFollowsSheet({
    super.key,
    required this.title,
    required this.icon,
    required this.userId,
    required this.type,
  });

  final String title;
  final IconData icon;
  final int userId;
  final StatsFollowsType type;

  @override
  State<StatsFollowsSheet> createState() => _StatsFollowsSheetState();
}

class _StatsFollowsSheetState extends State<StatsFollowsSheet> {
  late final Future<List<StatsFollow>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchUsers();
  }

  Future<List<StatsFollow>> _fetchUsers() {
    switch (widget.type) {
      case StatsFollowsType.following:
        return StatsService.getFollowing(widget.userId);
      case StatsFollowsType.followers:
        return StatsService.getFollowers(widget.userId);
      case StatsFollowsType.friendsAverageRating:
        return StatsService.getFriendsAverageRating(widget.userId);
    }
  }

  String _getEmptyText() {
    switch (widget.type) {
      case StatsFollowsType.following:
        return 'Нет подписок';
      case StatsFollowsType.followers:
        return 'Нет подписчиков';
      case StatsFollowsType.friendsAverageRating:
        return 'Нет подписок — подпишись на друзей!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: FutureBuilder<List<StatsFollow>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Не удалось загрузить'));
          }

          final users = snapshot.data!;

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
                  child: users.isEmpty
                      ? Center(
                          child: Text(
                            _getEmptyText(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            return _FollowTile(
                              user: users[index],
                              showRating: widget.type ==
                                  StatsFollowsType.friendsAverageRating,
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

class _FollowTile extends StatelessWidget {
  const _FollowTile({
    required this.user,
    required this.showRating,
  });

  final StatsFollow user;
  final bool showRating;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildAvatar(),
      title: Text(
        user.displayName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('@${user.username}'),
      // trailing: showRating ? _buildRatingBadge() : null,
      trailing: showRating ? RatingBadge(rating: user.averageRating ?? 0) : null,
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

  Widget _buildAvatar() {
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

}
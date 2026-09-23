import 'package:flutter/material.dart';

import 'package:lays_rating/models/user_brief.dart';
import 'package:lays_rating/widgets/profile/friends/friends_mini_card.dart';

/// Список пользователей с обработкой пустого состояния и pull-to-refresh.
class FriendsList extends StatelessWidget {
  const FriendsList({
    super.key,
    required this.users,
    required this.isLoading,
    required this.emptyText,
    required this.onRefresh,
    required this.myFollowingIds,
    required this.onToggleFollow,
    required this.onReturn,
  });

  final List<UserBrief>? users;
  final bool isLoading;
  final String emptyText;
  final Future<void> Function() onRefresh;
  final Set<int> myFollowingIds;

  final void Function(UserBrief user, bool wasFollowing) onToggleFollow;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (users == null && isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (users != null && users!.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.6,
              child: Center(
                child: Text(
                  emptyText,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(6),
        itemCount: users!.length,
        itemBuilder: (context, index) {
          final user = users![index];
          final isFollowing = myFollowingIds.contains(user.id);

          return FriendsMiniCard(
            user: user,
            isFollowing: isFollowing,
            onToggleFollow: () => onToggleFollow(user, isFollowing),
            onReturn: onReturn,
          );
        },
      ),
    );
  }
}
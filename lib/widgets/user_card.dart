import 'package:flutter/material.dart';
import 'package:lays_rating/models/user_brief.dart';
import 'package:lays_rating/services/follow_service.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/pages/profile/public_profile_page.dart';

class UserCard extends StatefulWidget {
  final UserBrief user;

  const UserCard({
    super.key,
    required this.user,
  });

  @override
  State<UserCard> createState() => UserCardState();
}

class UserCardState extends State<UserCard> {
  bool? _isFollowing;
  bool _isLoading = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {
    try {
      final status = await FollowService.checkFollowing(widget.user.id);
      if (mounted) {
        setState(() => _isFollowing = status.isFollowing);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFollowing = false);
      }
    }
  }

  Future<void> _toggleFollow() async {
    if (_isLoading || _isFollowing == null) return;

    setState(() => _isLoading = true);
    try {
      if (_isFollowing == true) {
        await FollowService.unfollowUser(widget.user.id);
        if (mounted) setState(() => _isFollowing = false);
      } else {
        await FollowService.followUser(widget.user.id);
        if (mounted) setState(() => _isFollowing = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Не удалось выполнить действие')
          ),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: theme.colorScheme.primaryContainer,
          backgroundImage: widget.user.avatarUrl != null
              ? NetworkImage('${AuthService.baseUrl}${widget.user.avatarUrl}')
              : null,
          child: widget.user.avatarUrl == null
              ? Text(
                  widget.user.displayName.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                )
              : null,
        ),
        title: Text(
          widget.user.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('@${widget.user.username}'),
        trailing: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.80 : 1.0,
            duration: const Duration(milliseconds: 110),
            child: _isFollowing == true
                ? ElevatedButton(
                    onPressed: _toggleFollow,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      minimumSize: const Size(100, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Отписаться',
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _toggleFollow,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      minimumSize: const Size(100, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: theme.colorScheme.inversePrimary,
                      foregroundColor: theme.colorScheme.onSurface,
                      elevation: 2,
                    ),
                    child: const Text(
                      'Подписаться',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PublicProfilePage(userId: widget.user.id),
            ),
          ).then((_) {
            if (mounted) {
              _checkFollowStatus();
            }
          });
        },
      ),
    );
  }
}
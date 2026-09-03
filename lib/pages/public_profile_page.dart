import 'package:flutter/material.dart';
import 'package:lays_rating/models/user.dart';
import '../models/user_stats.dart';
import 'package:lays_rating/services/follow_service.dart';
import 'package:lays_rating/services/user_service.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/widgets/stats_carousel.dart';



class PublicProfilePage extends StatefulWidget {
  final int userId;

  const PublicProfilePage({
    super.key,
    required this.userId,
  });

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  User? user;
  UserStats? stats;
  bool isLoading = true;
  bool? isFollowing;
  int followersCount = 0;
  int followingCount = 0;
  bool isFollowLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userData = await UserService.getUserById(widget.userId);
      final userStats = await UserService.getUserStats(widget.userId); // ← добавили
      final followStatus = await FollowService.checkFollowing(widget.userId);

      if (mounted) {
        setState(() {
          user = userData;
          stats = userStats;
          isFollowing = followStatus.isFollowing;
          followersCount = followStatus.followersCount;
          followingCount = followStatus.followingCount;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _toggleFollow() async {
    setState(() => isFollowLoading = true);

    try {
      if (isFollowing == true) {
        await FollowService.unfollowUser(widget.userId);
        if (mounted) {
          setState(() {
            isFollowing = false;
            followersCount--;
          });
        }
      } else {
        await FollowService.followUser(widget.userId);
        if (mounted) {
          setState(() {
            isFollowing = true;
            followersCount++;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось выполнить действие')),
        );
      }
    }

    if (mounted) setState(() => isFollowLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Пользователь не найден')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(user!.displayName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Аватар
            CircleAvatar(
              radius: 70,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage: user!.avatarUrl != null
                  ? NetworkImage('${AuthService.baseUrl}${user!.avatarUrl}')
                  : null,
              child: user!.avatarUrl == null
                  ? Text(
                      user!.displayName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),

            // Имя
            Text(
              user!.displayName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Username
            Text(
              "@${user!.username}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            // Статистика подписки
            SizedBox(
              height: 100,
              child: InfiniteStatsCarousel(
                items: [
                  StatSquareData(
                    icon: Icons.star_rounded,
                    label: 'Оценок',
                    value: '${stats?.ratingsCount ?? 0}',
                  ),
                  StatSquareData(
                    icon: Icons.favorite_rounded,
                    label: 'Любимчиков',
                    value: '${stats?.favoritesCount ?? 0}',
                  ),
                  StatSquareData(
                    icon: Icons.check_circle_rounded,
                    label: 'Пробовал',
                    value: '${stats?.triedCount ?? 0}',
                  ),
                  StatSquareData(
                    icon: Icons.chat_bubble_rounded,
                    label: 'Комментариев',
                    value: '${stats?.commentsCount ?? 0}',
                  ),
                  StatSquareData(
                    icon: Icons.trending_up_rounded,
                    label: 'Средняя',
                    value: '${stats?.averageRating ?? 0.0}',
                  ),
                  StatSquareData(
                    icon: Icons.groups_rounded,
                    label: 'Подписчиков',
                    value: '${stats?.followersCount ?? 0}',
                  ),
                  StatSquareData(
                    icon: Icons.person_add_alt_rounded,
                    label: 'Подписок',
                    value: '${stats?.followingCount ?? 0}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Кнопка подписаться
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isFollowLoading ? null : _toggleFollow,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: isFollowing == true
                      ? theme.colorScheme.surfaceContainerHighest
                      : theme.colorScheme.primary,
                  foregroundColor: isFollowing == true
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onPrimary,
                ),
                child: isFollowLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isFollowing == true ? 'Отписаться' : 'Подписаться',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}


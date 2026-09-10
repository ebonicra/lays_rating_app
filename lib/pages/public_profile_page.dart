import 'package:flutter/material.dart';
import 'package:lays_rating/models/user.dart';
import '../models/user_stats.dart';
import 'package:lays_rating/services/follow_service.dart';
import 'package:lays_rating/services/user_service.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/widgets/stats_carousel.dart';
import 'package:lays_rating/widgets/photo_carousel.dart';


import '../widgets/stats_details_sheet.dart';
import '../widgets/follows_detail_sheet.dart';


import '../services/stats_service.dart';


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
  bool isFollowingMe = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _checkIfFollowingMe() async {
    final myUser = UserService.currentUser;
    if (myUser == null) return;

    try {
      final theirFollowing = await FollowService.getFollowing(userId: widget.userId);
      if (mounted) {
        setState(() {
          isFollowingMe = theirFollowing.any((u) => u.id == myUser.id);
        });
      }
    } catch (e) {
      // молча — не критично
    }
  }

  Future<void> _loadData() async {
    try {
      final userData = await UserService.getUserById(widget.userId);
      final userStats = await StatsService.getUserStats(widget.userId); // ← добавили
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
        await _checkIfFollowingMe();
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


            // Карточка пользователя (фото, имя, ник, дата)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                    Theme.of(context).colorScheme.surface,  
                    Theme.of(context).colorScheme.inversePrimary,
                    Theme.of(context).colorScheme.surface,  
                    Theme.of(context).colorScheme.inversePrimary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.8),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 60,
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform.translate(
                          offset: const Offset(-6, 0),
                          child: Text(
                            user!.displayName,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Text(
                          "@${user!.username}",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Transform.translate(
                          offset: const Offset(-6, 0),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(user!.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Статистика подписки
            SizedBox(
              height: 100,
              child: InfiniteStatsCarousel(
                items: [
                  StatSquareData(
                    icon: Icons.star_rounded,
                    label: 'Оценок',
                    value: '${stats?.ratingsCount ?? 0}',
                    onTap: () => _showRatingsDetails(),
                  ),
                  StatSquareData(
                    icon: Icons.favorite_rounded,
                    label: 'Любимчиков',
                    value: '${stats?.favoritesCount ?? 0}',
                    onTap: () => _showFavoritesDetails(),
                  ),
                  StatSquareData(
                    icon: Icons.check_circle_rounded,
                    label: 'Пробовал',
                    value: '${stats?.triedCount ?? 0}',
                    onTap: () => _showTriedDetails(),
                  ),
                  StatSquareData(
                    icon: Icons.chat_bubble_rounded,
                    label: 'Комментариев',
                    value: '${stats?.commentsCount ?? 0}',
                    onTap: () => _showCommentsDetails(),
                  ),
                  StatSquareData(
                    icon: Icons.trending_up_rounded,
                    label: 'Средняя',
                    value: '${stats?.averageRating ?? 0.0}',
                    onTap: () => _showFollowingWithRatingDetails(),
                  ),
                  StatSquareData(
                    icon: Icons.groups_rounded,
                    label: 'Подписчиков',
                    value: '${stats?.followersCount ?? 0}',
                    onTap: () => _showFollowersDetails(),
                  ),
                  StatSquareData(
                    icon: Icons.person_add_alt_rounded,
                    label: 'Подписок',
                    value: '${stats?.followingCount ?? 0}',
                    onTap: () => _showFollowingDetails(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            
            PhotoCarousel(
              userId: user!.id,
              isMyProfile: false, // ← false, потому что это чужой профиль
            ),
            const SizedBox(height: 35),

            // Плашка статуса подписки на вас
            Container(
              width: double.infinity, 
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isFollowingMe
                    ? theme.colorScheme.primaryContainer.withOpacity(0.5)
                    : theme.colorScheme.surfaceContainerHighest,
                border: Border.all(
                  color: isFollowingMe
                      ? theme.colorScheme.primary.withOpacity(0.3)
                      : theme.colorScheme.outlineVariant.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isFollowingMe
                        ? Icons.check_circle_rounded
                        : Icons.cancel_outlined,
                    size: 16,
                    color: isFollowingMe
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isFollowingMe ? 'Подписан на вас' : 'Не подписан на вас',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isFollowingMe
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  // const SizedBox(width: 6),
                  // Icon(
                  //   isFollowingMe
                  //       ? Icons.check_circle_rounded
                  //       : Icons.cancel_outlined,
                  //   size: 16,
                  //   color: isFollowingMe
                  //       ? theme.colorScheme.primary
                  //       : theme.colorScheme.onSurfaceVariant,
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 4),




            // Кнопка подписаться
            _MiniActionButton(
              // icon: Icons.fastfood_rounded,
              label: isFollowing == true ? 'Отписаться' : 'Подписаться',
              active: isFollowing == true,
              activeColor: Color(0xFF00E676),
              onTap:_toggleFollow,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }


  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }


  
  void _showFavoritesDetails() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ChipsDetailSheet(
        title: 'Любимчики',
        icon: Icons.favorite_rounded,
        userId: widget.userId,
        type: ChipsListType.favorites,
      ),
    );
  }

  void _showTriedDetails() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ChipsDetailSheet(
        title: 'Пробовал',
        icon: Icons.check_circle_rounded,
        userId: widget.userId,
        type: ChipsListType.tried,
      ),
    );
  }

  void _showRatingsDetails() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ChipsDetailSheet(
        title: 'Оценки',
        icon: Icons.star_rounded,
        userId: widget.userId,
        type: ChipsListType.ratings,
      ),
    );
  }


  void _showFollowingDetails() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FollowsDetailSheet(
        title: 'Подписки',
        icon: Icons.person_add_alt_rounded,
        userId: widget.userId,
        type: FollowsSheetType.following,
      ),
    );
  }

  void _showFollowersDetails() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FollowsDetailSheet(
        title: 'Подписчики',
        icon: Icons.group_rounded,
        userId: widget.userId,
        type: FollowsSheetType.followers,
      ),
    );
  }

  void _showFollowingWithRatingDetails() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FollowsDetailSheet(
        title: 'Средняя оценка друзей',
        icon: Icons.trending_up_rounded,
        userId: widget.userId,
        type: FollowsSheetType.friendsAverageRating,
      ),
    );
  }

  void _showCommentsDetails() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ChipsDetailSheet(
        title: 'Комментариев',
        icon: Icons.chat_bubble_rounded,
        userId: widget.userId,
        type: ChipsListType.comments,
      ),
    );
  }
}



class _MiniActionButton extends StatefulWidget {
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _MiniActionButton({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  State<_MiniActionButton> createState() => _MiniActionButtonState();
}

class _MiniActionButtonState extends State<_MiniActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.80 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (value) {
            setState(() => _pressed = value);
          },
          borderRadius: BorderRadius.circular(16),

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: widget.active
                  ? theme.colorScheme.inversePrimary.withOpacity(0.8)
                  : theme.colorScheme.background,
              border: Border.all(
                color: widget.active
                    ? theme.colorScheme.inversePrimary
                    : theme.colorScheme.outlineVariant,
              ),
              boxShadow: widget.active
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.inversePrimary.withOpacity(0.8),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: theme.colorScheme.outlineVariant.withOpacity(0.8),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.active
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

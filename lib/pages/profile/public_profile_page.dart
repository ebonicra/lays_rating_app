import 'package:flutter/material.dart';

import 'package:lays_rating/models/user.dart';
import 'package:lays_rating/models/user_stats.dart';

import 'package:lays_rating/services/follow_service.dart';
import 'package:lays_rating/services/stats_service.dart';
import 'package:lays_rating/services/user_service.dart';

import 'package:lays_rating/widgets/profile/photos/photo_carousel.dart';
import 'package:lays_rating/widgets/profile/profile_follow_button.dart';
import 'package:lays_rating/widgets/profile/profile_follows_me_badge.dart';
import 'package:lays_rating/widgets/profile/profile_header.dart';
import 'package:lays_rating/widgets/profile/profile_stats_carousel.dart';


class PublicProfilePage extends StatefulWidget {
  const PublicProfilePage({
    super.key,
    required this.userId,
  });

  final int userId;

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  User? user;
  UserStats? stats;
  bool isLoading = true;

  bool? isFollowing;
  bool isFollowLoading = false;
  bool isFollowingMe = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userData = await UserService.getUserById(widget.userId);
      final userStats = await StatsService.getUserStats(widget.userId);
      final followStatus = await FollowService.checkFollowing(widget.userId);

      if (!mounted) return;
      setState(() {
        user = userData;
        stats = userStats;
        isFollowing = followStatus.isFollowing;
        isLoading = false;
      });

      await _checkIfFollowingMe();
    } catch (e) {
      debugPrint('PublicProfilePage._loadData error: $e');
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> _checkIfFollowingMe() async {
    final myUser = UserService.currentUser;
    if (myUser == null) return;

    try {
      final theirFollowing =
          await FollowService.getFollowing(userId: widget.userId);
      if (!mounted) return;
      setState(() {
        isFollowingMe = theirFollowing.any((u) => u.id == myUser.id);
      });
    } catch (e) {
      debugPrint('PublicProfilePage._checkIfFollowingMe error: $e');
    }
  }

  Future<void> _toggleFollow() async {
    setState(() => isFollowLoading = true);

    try {
      if (isFollowing == true) {
        await FollowService.unfollowUser(widget.userId);
        if (!mounted) return;
        setState(() => isFollowing = false);
      } else {
        await FollowService.followUser(widget.userId);
        if (!mounted) return;
        setState(() => isFollowing = true);
      }

      // Обновляем статистику, чтобы счётчики подписчиков совпадали.
      final updatedStats = await StatsService.getUserStats(widget.userId);
      if (!mounted) return;
      setState(() => stats = updatedStats);
    } catch (e) {
      debugPrint('PublicProfilePage._toggleFollow error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось выполнить действие')),
      );
    } finally {
      if (mounted) setState(() => isFollowLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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

            ProfileHeader(user: user!),
            const SizedBox(height: 25),

            ProfileStatsCarousel(stats: stats, userId: widget.userId),
            const SizedBox(height: 8),

            ProfilePhotoCarousel(userId: user!.id, isMyProfile: false),
            const SizedBox(height: 8),

            ProfileFollowsMeBadge(isFollowingMe: isFollowingMe),
            const SizedBox(height: 4),

            ProfileFollowButton(
              isFollowing: isFollowing == true,
              isLoading: isFollowLoading,
              onTap: _toggleFollow,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
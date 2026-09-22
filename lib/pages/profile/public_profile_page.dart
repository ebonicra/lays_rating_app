import 'package:flutter/material.dart';

import 'package:lays_rating/pages/profile/public_profile_controller.dart';
import 'package:lays_rating/widgets/profile/photos/photo_carousel.dart';
import 'package:lays_rating/widgets/profile/profile_follow_button.dart';
import 'package:lays_rating/widgets/profile/profile_follows_me_badge.dart';
import 'package:lays_rating/widgets/profile/profile_header.dart';
import 'package:lays_rating/widgets/profile/stats/profile_stats_carousel.dart';


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
  late final PublicProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PublicProfileController(userId: widget.userId);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleFollow() async {
    try {
      await _controller.toggleFollow();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось выполнить действие')
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_controller.isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final user = _controller.user;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Пользователь не найден')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(user.displayName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),

            ProfileHeader(user: user),
            const SizedBox(height: 25),

            ProfileStatsCarousel(
              stats: _controller.stats,
              userId: widget.userId,
            ),
            const SizedBox(height: 8),

            ProfilePhotoCarousel(userId: user.id, isMyProfile: false),
            const SizedBox(height: 8),

            ProfileFollowsMeBadge(isFollowingMe: _controller.isFollowingMe),
            const SizedBox(height: 4),

            ProfileFollowButton(
              isFollowing: _controller.isFollowing,
              isLoading: _controller.isFollowLoading,
              onTap: _toggleFollow,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
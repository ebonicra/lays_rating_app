import 'package:flutter/material.dart';

import 'package:lays_rating/pages/auth/login_page.dart';
import 'package:lays_rating/services/user_service.dart';
import 'package:lays_rating/pages/profile/profile_controller.dart';

import 'package:lays_rating/widgets/profile/photos/photo_carousel.dart';
import 'package:lays_rating/widgets/profile/admin/profile_admin_card.dart';
import 'package:lays_rating/widgets/profile/appearance/profile_appearance_card.dart';
import 'package:lays_rating/widgets/profile/profile_delete_account_dialog.dart';
import 'package:lays_rating/widgets/profile/profile_edit_dialog.dart';
import 'package:lays_rating/widgets/profile/profile_friends_card.dart';
import 'package:lays_rating/widgets/profile/profile_header.dart';
import 'package:lays_rating/widgets/profile/profile_logout_button.dart';
import 'package:lays_rating/widgets/profile/profile_menu_button.dart';
import 'package:lays_rating/widgets/profile/stats/profile_stats_carousel.dart';
import 'package:lays_rating/utils/route_observer.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with RouteAware {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController();
    _controller.load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);   // ←
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _controller.reloadStats();
  }

  Future<void> refresh() async {
    await _controller.reloadUser();
    await _controller.reloadStats();
  }

  Future<void> _logout() async {
    final confirmed = await confirmLogout(context);
    if (!confirmed || !mounted) return;

    await _controller.logout();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _showEditProfileDialog() async {
    final user = _controller.user;
    if (user == null) return;

    final saved = await ProfileEditDialog.show(context, user);
    if (saved == true && mounted) {
      await _controller.reloadUser();
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await ProfileDeleteAccountDialog.show(context);
    if (confirmed != true || !mounted) return;

    try {
      await UserService.deleteAccount();
      if (!mounted) return;

      await _controller.logout();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('ProfilePage._showDeleteAccountDialog error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось удалить аккаунт')
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
      return const Center(child: CircularProgressIndicator());
    }

    final user = _controller.user;
    if (user == null) {
      return const Center(child: Text('Не удалось загрузить профиль'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          ProfileMenuButton(
            onEdit: _showEditProfileDialog,
            onDelete: _showDeleteAccountDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const SizedBox(height: 10),

            ProfileHeader(user: user),
            const SizedBox(height: 15),

            ProfileStatsCarousel(stats: _controller.stats, userId: user.id),
            const SizedBox(height: 8),

            ProfilePhotoCarousel(userId: user.id, isMyProfile: true),
            const SizedBox(height: 15),

            const ProfileAppearanceCard(),
            const SizedBox(height: 2),

            ProfileFriendsCard(userId: user.id), // Не делала пока
            const SizedBox(height: 2),

            if (user.isAdmin) const ProfileAdminCard(),
            const SizedBox(height: 5),

            ProfileLogoutButton(onPressed: _logout),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../models/user_stats.dart';

import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/stats_service.dart';
import '../auth/login_page.dart';

import 'package:lays_rating/widgets/profile/photos/photo_carousel.dart';
import 'package:lays_rating/widgets/profile/profile_admin_card.dart';
import 'package:lays_rating/widgets/profile/profile_appearance_card.dart';
import 'package:lays_rating/widgets/profile/profile_delete_account_dialog.dart';
import 'package:lays_rating/widgets/profile/profile_edit_dialog.dart';
import 'package:lays_rating/widgets/profile/profile_friends_card.dart';
import 'package:lays_rating/widgets/profile/profile_header.dart';
import 'package:lays_rating/widgets/profile/profile_logout_button.dart';
import 'package:lays_rating/widgets/profile/profile_menu_button.dart';
import 'package:lays_rating/widgets/profile/profile_stats_carousel.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  UserStats? stats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await loadUser();
    await loadStats();
  }

  Future<void> loadUser() async {
    try {
      final result = await UserService.getCurrentUser();
      if (!mounted) return;
      setState(() {
        user = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('loadUser error: $e');
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> loadStats() async {
    if (user == null) return;
    try {
      final result = await StatsService.getUserStats(user!.id);
      if (!mounted) return;
      setState(() => stats = result);
    } catch (e, st) {
      debugPrint('loadStats error: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    UserService.currentUser = null;
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _showEditProfileDialog() async {
    final saved = await ProfileEditDialog.show(context, user!);
    if (saved == true && mounted) {
      await loadUser();
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await ProfileDeleteAccountDialog.show(context);
    if (confirmed != true || !mounted) return;

    // TODO: вызвать API удаления аккаунта, потом logout
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (user == null) {
      return const Center(
        child: Text('Не удалось загрузить профиль'),
      );
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

            ProfileHeader(user: user!),
            const SizedBox(height: 15),

            ProfileStatsCarousel(stats: stats, userId: user!.id),
            const SizedBox(height: 8),

            ProfilePhotoCarousel(userId: user!.id, isMyProfile: true),
            const SizedBox(height: 15),

            const ProfileAppearanceCard(),
            const SizedBox(height: 2),

            ProfileFriendsCard(userId: user!.id),
            const SizedBox(height: 2),

            if (user!.isAdmin) const ProfileAdminCard(),
            const SizedBox(height: 5),

            ProfileLogoutButton(onPressed: logout),
          ],
        ),
      ),
    );
  }
}
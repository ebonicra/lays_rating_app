import 'dart:io';

import 'package:flutter/material.dart';

import '../models/user.dart';
import '../models/user_stats.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/stats_service.dart';
import '../services/avatar_service.dart';
import '../pages/auth/login_page.dart';

import 'package:lays_rating/widgets/profile/photos/photo_carousel.dart';
import '../widgets/profile/profile_appearance_card.dart';


import 'package:lays_rating/widgets/profile/profile_header.dart';
import 'package:lays_rating/widgets/profile/profile_stats_carousel.dart';
import 'package:lays_rating/widgets/profile/profile_friends_card.dart';
import 'package:lays_rating/widgets/profile/profile_admin_card.dart';



class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  String? avatarPath;
  UserStats? stats;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
    loadStats();
  }

  Future<void> loadStats() async {
    try {
      final result = await StatsService.getMyStats();
      if (!mounted) return;
      setState(() => stats = result);
    } catch (e, st) {
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> loadUser() async {
    try {
      final result = await UserService.getCurrentUser();
      setState(() {
        user = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> changeAvatar() async {
    try {
      await AvatarService.uploadAvatar();
      await loadUser();
    } catch (e) {
      // ошибка
    }
  }

  Future<void> deleteAvatar() async {
    try {
      await AvatarService.deleteAvatar();
      await loadUser();
    } catch (e) {
      // ошибка
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    UserService.currentUser = null;   // ← сброс кэша
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (user == null) {
      return const Center(
        child: Text("Не удалось загрузить профиль"),
      );
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            constraints: const BoxConstraints(maxWidth: 200),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _showEditProfileDialog();
                  break;
                case 'delete':
                  _showDeleteAccountDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                height: 40,
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined, size: 20),
                    title: Text('Редактировать', style: TextStyle(fontSize: 14)),
                    contentPadding: EdgeInsets.zero,
                  ),
              ),
              const PopupMenuItem(
                value: 'delete',
                height: 40,
                child: ListTile(
                  leading: Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  title: Text('Удалить аккаунт', style: TextStyle(color: Colors.red, fontSize: 14)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Аватар + имя + username
            ProfileHeader(user: user!),
            const SizedBox(height: 15),

            // Статистика
            ProfileStatsCarousel(stats: stats, userId: user!.id),
            const SizedBox(height: 8),

            // Карусель фото
            ProfilePhotoCarousel(userId: user!.id, isMyProfile: true),
            const SizedBox(height: 15),

            // Настройки внешнего вида
            const ProfileAppearanceCard(),
            const SizedBox(height: 2),

            // Друзья
            ProfileFriendsCard(userId: user!.id),
            const SizedBox(height: 2),

            // Админка
            if (user!.isAdmin) const ProfileAdminCard(),
            const SizedBox(height: 5),

            // Кнопка выхода
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: logout,
                icon: const Icon(Icons.logout),
                label: const Text("Выйти"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }




  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: user!.displayName);
    final usernameController = TextEditingController(text: user!.username);
    
    String? _localAvatarUrl = user!.avatarUrl;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text(
                'Редактировать профиль',
                textAlign: TextAlign.center, // ← выравнивание текста
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Аватарка (локальная)
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.photo),
                                  title: const Text("Выбрать фото"),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    // Выбираем новое фото, но НЕ загружаем на сервер
                                    final newAvatarPath = await AvatarService.pickLocalAvatar();
                                    if (newAvatarPath != null) {
                                      setStateDialog(() {
                                        _localAvatarUrl = newAvatarPath; // ← локальное фото
                                      });
                                    }
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.delete),
                                  title: const Text("Удалить фото"),
                                  onTap: () {
                                    Navigator.pop(context);
                                    setStateDialog(() {
                                      _localAvatarUrl = null; // ← убрали локально
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: _localAvatarUrl != null
                              ? (_localAvatarUrl!.startsWith('/users/avatars/')
                                  ? NetworkImage('${AuthService.baseUrl}$_localAvatarUrl')  // ← относительный путь
                                  : _localAvatarUrl!.startsWith('http')
                                      ? NetworkImage(_localAvatarUrl!)  // ← полный URL
                                      : FileImage(File(_localAvatarUrl!)))  // ← локальный файл
                              : null,
                          child: _localAvatarUrl == null
                              ? Text(
                                  user!.displayName.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Имя
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Имя',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Username
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // 1. Загружаем аватарку на сервер (если выбрана локальная)
                      if (_localAvatarUrl != null && !_localAvatarUrl!.startsWith('http')) {
                        await AvatarService.uploadLocalAvatar(_localAvatarUrl!);
                      } else if (_localAvatarUrl == null && user!.avatarUrl != null) {
                        await AvatarService.deleteAvatar();
                      }

                      // 2. Обновляем имя и username
                      await UserService.updateProfile(
                        displayName: nameController.text.trim(),
                        username: usernameController.text.trim(),
                      );

                      if (mounted) {
                        Navigator.pop(context);
                        await loadUser(); // ← теперь обновляем основной профиль
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ Сохранено')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('❌ Ошибка: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить аккаунт?'),
        content: const Text('Это действие нельзя отменить. Все оценки, комментарии и подписки будут удалены.'),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    // TODO: вызвать API для удаления
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Удалить'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

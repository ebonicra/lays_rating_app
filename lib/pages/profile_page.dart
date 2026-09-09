import 'dart:io';

import 'package:flutter/material.dart';

import '../models/user.dart';
import '../models/user_stats.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/stats_service.dart';
import '../services/avatar_service.dart';
import '../pages/auth/login_page.dart';
import '../pages/friends_page.dart';
import '../pages/admin/admin_page.dart';

import '../widgets/color_picker_sheet.dart';
import '../widgets/theme_picker_sheet.dart';
import '../widgets/stats_details_sheet.dart';
import '../widgets/follows_detail_sheet.dart';
import '../app/app.dart';

import 'package:lays_rating/widgets/stats_carousel.dart';



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
      setState(() => stats = result);
    } catch (e) {
      // молча, не критично
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
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = AppThemeState.instance.accentColor;
    final currentTheme = AppThemeState.instance.themeMode;

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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                    Theme.of(context).colorScheme.inversePrimary,
                    Theme.of(context).colorScheme.surface,  
                    Theme.of(context).colorScheme.inversePrimary,
                    Theme.of(context).colorScheme.surface,  
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
                    backgroundImage: user?.avatarUrl != null
                        ? NetworkImage('${AuthService.baseUrl}${user!.avatarUrl}')
                        : null,
                    child: user?.avatarUrl == null
                        ? Text(
                            user!.displayName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
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

            // Статистика
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
                    icon: Icons.group_rounded,
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
            const SizedBox(height: 10),

            // Настройки
            Card(
              child: Column(
                children: [

                  // Цвет приложения
                  ListTile(
                    leading: const Icon(Icons.color_lens),
                    title: const Text("Цвет приложения"),
                    subtitle: Text(_getColorName(currentColor)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => ColorWheelDialog(
                          currentColor: currentColor,
                          onColorChanged: (color) {
                            AppThemeState.instance.setAccentColor(color);
                            setState(() {});
                          },
                        ),
                      );
                    },
                  ),
                  // Тема приложения
                  ListTile(
                    leading: const Icon(Icons.brightness_6_rounded),
                    title: const Text("Тема приложения"),
                    subtitle: Text(_getThemeName(currentTheme)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => ThemeWheelDialog(
                          currentTheme: currentTheme,
                          onThemeChanged: (mode) {
                            AppThemeState.instance.setThemeMode(mode);
                            setState(() {});
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),

            // Друзья
            Card(
              child: ListTile(
                leading: Icon(Icons.group_rounded),
                title: const Text("Друзья и приятели"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FriendsPage(userId: user!.id),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 5),

            // Админка
            if (user!.isAdmin) ...[
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.red.shade400,
                  ),
                  title: const Text("Админ-панель"),
                  subtitle: const Text("Управление приложением"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminPage()),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 10),


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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _getColorName(String color) {
    switch (color) {
      case 'pink':
        return 'Розовый';
      case 'blue':
        return 'Синий';
      case 'black':
        return 'Чёрный';
      default:
        return 'Розовый';
    }
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Светлая';
      case ThemeMode.dark:
        return 'Тёмная';
      case ThemeMode.system:
        return 'Системная';
    }
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

  void _showFavoritesDetails() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ChipsDetailSheet(
        title: 'Любимчики',
        icon: Icons.favorite_rounded,
        userId: user!.id,
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
        userId: user!.id,
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
        userId: user!.id,
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
        userId: user!.id,
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
        userId: user!.id,
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
        userId: user!.id,
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
        userId: user!.id,
        type: ChipsListType.comments,
      ),
    );
  }

}

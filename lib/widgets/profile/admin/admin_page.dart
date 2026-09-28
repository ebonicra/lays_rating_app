import 'package:flutter/material.dart';

import 'package:lays_rating/services/feedback_service.dart';
import 'package:lays_rating/services/user_service.dart';
import 'package:lays_rating/widgets/profile/admin/admin_menu_card.dart';
import 'package:lays_rating/widgets/profile/admin/chips/create_chip_page.dart';
import 'package:lays_rating/widgets/profile/admin/feedback/admin_feedback_page.dart';
import 'package:lays_rating/widgets/profile/admin/manage_admins/manage_admins_page.dart';
import 'package:lays_rating/widgets/profile/admin/news/create_news_page.dart';

/// Админ-панель: управление админами, чипсами, новостями и обратной связью.
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _unreadCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnread();
  }

  Future<void> _loadUnread() async {
    try {
      final data = await FeedbackService.getList(
        isRead: false,
        page: 1,
        perPage: 1,
      );
      if (!mounted) return;
      setState(() {
        _unreadCount = data.unreadCount;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('AdminPage._loadUnread error: $e');
      if (!mounted) return;
      setState(() {
        _unreadCount = 0;
        _isLoading = false;
      });
    }
  }

  Future<void> _openFeedback() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminFeedbackPage()),
    );
    // После возврата — обновляем счётчик
    await _loadUnread();
  }

  @override
  Widget build(BuildContext context) {
    final isSuperAdmin = UserService.currentUser?.isSuperAdmin ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Админ-панель')),
      body: RefreshIndicator(
        onRefresh: _loadUnread,
        child: ListView(
          padding: const EdgeInsets.all(10),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (isSuperAdmin)
              AdminMenuCard(
                icon: Icons.people_rounded,
                title: 'Управление админами',
                subtitle: 'Назначить или снять админа',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageAdminsPage(),
                  ),
                ),
              ),
            AdminMenuCard(
              icon: Icons.fastfood_rounded,
              title: 'Создать чипсы',
              subtitle: 'Новый вкус',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateChipPage()),
              ),
            ),
            AdminMenuCard(
              icon: Icons.newspaper_rounded,
              title: 'Создать новость',
              subtitle: 'Посты, слухи, анонсы',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateNewsPage()),
              ),
            ),
            AdminMenuCard(
              icon: Icons.mail_outline_rounded,
              title: 'Обратная связь',
              subtitle: _isLoading
                  ? 'Загрузка...'
                  : _unreadCount > 0
                      ? 'Непрочитанных: $_unreadCount'
                      : 'Сообщения от пользователей',
              badgeCount: _unreadCount,
              onTap: _openFeedback,
            ),
          ],
        ),
      ),
    );
  }
}
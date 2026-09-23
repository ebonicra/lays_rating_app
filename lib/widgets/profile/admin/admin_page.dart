import 'package:flutter/material.dart';


import 'package:lays_rating/widgets/profile/admin/manage_admins/manage_admins_page.dart';
import 'package:lays_rating/services/user_service.dart';
import 'package:lays_rating/widgets/profile/admin/admin_menu_card.dart';
import 'package:lays_rating/widgets/profile/admin/chips/create_chip_page.dart';
import 'package:lays_rating/widgets/profile/admin/news/create_news_page.dart';

/// Админ-панель: управление админами, чипсами и новостями.
class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isSuperAdmin = UserService.currentUser?.isSuperAdmin ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Админ-панель')),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          if (isSuperAdmin) ...[
            AdminMenuCard(
              icon: Icons.people_rounded,
              title: 'Управление админами',
              subtitle: 'Назначить или снять админа',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageAdminsPage()),
              ),
            ),
          ],
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
        ],
      ),
    );
  }
}
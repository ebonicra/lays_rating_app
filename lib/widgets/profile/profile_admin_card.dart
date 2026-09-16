import 'package:flutter/material.dart';

import 'package:lays_rating/pages/admin/admin_page.dart';


class ProfileAdminCard extends StatelessWidget {
  const ProfileAdminCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.admin_panel_settings_rounded,
          color: Colors.red.shade400,
        ),
        title: const Text('Админ-панель'),
        subtitle: const Text('Управление приложением'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminPage()),
          );
        },
      ),
    );
  }
}
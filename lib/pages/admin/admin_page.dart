import 'package:flutter/material.dart';
import 'package:lays_rating/pages/admin/create_news_page.dart';
import 'package:lays_rating/pages/admin/edit_chip_page.dart';
import 'package:lays_rating/pages/admin/manage_admins_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Админ-панель'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: ListTile(
                leading: Icon(
                  Icons.people_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                title: const Text(
                  'Управление админами',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: const Text(
                  'Назначить или снять админа',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ManageAdminsPage()),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 2),

          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: ListTile(
                leading: Icon(
                  Icons.fastfood_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                title: const Text(
                  'Создать чипсы',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: const Text(
                  'Новый вкус',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditChipPage(chip: null)),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 2),

          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14), // ← выше карточка
              child: ListTile(
                leading: Icon(
                  Icons.newspaper_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                title: const Text(
                  'Создать новость',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: const Text(
                  'Посты, слухи, анонсы',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateNewsPage()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
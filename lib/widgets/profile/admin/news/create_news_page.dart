import 'package:flutter/material.dart';

import 'package:lays_rating/widgets/profile/admin/news/admin_post_page.dart';
import 'package:lays_rating/widgets/profile/admin/news/poll_page.dart';
import 'package:lays_rating/widgets/profile/admin/news/rumor_page.dart';

/// Выбор типа новости для создания.
class CreateNewsPage extends StatelessWidget {
  const CreateNewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Создать новость')),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          _NewsTypeCard(
            icon: Icons.campaign_rounded,
            title: 'Обычный пост',
            subtitle: 'Текст и картинки от админа',
            onTap: () => _open(context, const AdminPostPage()),
          ),
          const SizedBox(height: 2),
          _NewsTypeCard(
            icon: Icons.psychology_rounded,
            title: 'Слухи',
            subtitle: 'Новый вкус, утечка, инсайд',
            onTap: () => _open(context, const RumorPage()),
          ),
          const SizedBox(height: 2),
          _NewsTypeCard(
            icon: Icons.poll_rounded,
            title: 'Опрос',
            subtitle: 'Вопрос с вариантами ответа',
            onTap: () => _open(context, const PollPage()),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }
}

/// Карточка выбора типа новости.
class _NewsTypeCard extends StatelessWidget {
  const _NewsTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: ListTile(
          leading: Icon(
            icon,
            color: colorScheme.primary,
            size: 28,
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}
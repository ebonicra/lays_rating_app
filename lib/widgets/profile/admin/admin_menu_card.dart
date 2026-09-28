import 'package:flutter/material.dart';

/// Карточка-пункт в админ-панели.
class AdminMenuCard extends StatelessWidget {
  const AdminMenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: ListTile(
          leading: Badge(
            isLabelVisible: badgeCount > 0,
            label: Text('$badgeCount'),
            backgroundColor: colorScheme.error,
            textColor: colorScheme.onError,
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 28,
            ),
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
import 'package:flutter/material.dart';

import 'package:lays_rating/models/news_item.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/utils/date_formatter.dart';
import 'package:lays_rating/utils/initials.dart';

class NewFollowerContent extends StatelessWidget {
  const NewFollowerContent({
    super.key,
    required this.item,
  });

  final NewsItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = item.user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.person_add_rounded,
              size: 14,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            const Text(
              'У вас новый подписчик!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: user?.avatarUrl != null
                  ? NetworkImage(
                      '${AuthService.baseUrl}${user!.avatarUrl}',
                    )
                  : null,
              child: user?.avatarUrl == null
                  ? Text(
                      initialOf(user?.displayName ?? '?'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '@${user?.username ?? 'user'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatRelativeDate(item.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';

import 'package:lays_rating/utils/date_formatter.dart';
import 'package:lays_rating/models/user.dart';
import 'package:lays_rating/services/auth_service.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.user,
    this.onAvatarTap,
  });

  final User user;
  final VoidCallback? onAvatarTap;

  String get _initial {
    final name = user.displayName.trim();
    if (name.isEmpty) return '?';
    return name.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.onPrimaryContainer.withOpacity(0.7),
            colorScheme.inversePrimary,
            colorScheme.surface,
            colorScheme.inversePrimary,
            colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.inversePrimary.withOpacity(0.8),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onAvatarTap,
            customBorder: const CircleBorder(),
            child: CircleAvatar(
              radius: 60,
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage('${AuthService.baseUrl}${user.avatarUrl}')
                  : null,
              child: user.avatarUrl == null
                  ? Text(
                      _initial,
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: const Offset(-6, 0),
                  child: Text(
                    user.displayName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "@${user.username}",
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Transform.translate(
                  offset: const Offset(-6, 0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatShortDate(user.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
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
    );
  }
}
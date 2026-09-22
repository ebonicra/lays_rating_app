import 'package:flutter/material.dart';

import 'package:lays_rating/models/user.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/utils/date_formatter.dart';
import 'package:lays_rating/utils/initials.dart';
import 'package:lays_rating/widgets/common/full_screen_gallery.dart';


class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.user,
    this.onAvatarTap,
  });

  final User user;
  final VoidCallback? onAvatarTap;

  VoidCallback? _defaultAvatarTap(BuildContext context) {
    if (user.avatarUrl == null) return null;

    return () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullScreenGallery(
            imageUrls: ['${AuthService.baseUrl}${user.avatarUrl}'],
            initialIndex: 0,
          ),
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
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
            color: colorScheme.inversePrimary.withValues(alpha: 0.8),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onAvatarTap ?? _defaultAvatarTap(context),
            customBorder: const CircleBorder(),
            child: CircleAvatar(
              radius: 60,
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage('${AuthService.baseUrl}${user.avatarUrl}')
                  : null,
              child: user.avatarUrl == null
                  ? Text(
                      initialOf(user.displayName),
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
                  offset: const Offset(-7, 0),
                  child: Text(
                    user.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '@${user.username}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Transform.translate(
                  offset: const Offset(-7, 0),
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
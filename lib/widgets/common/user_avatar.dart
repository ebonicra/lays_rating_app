import 'package:flutter/material.dart';

import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/utils/initials.dart';

/// Аватар пользователя: картинка или инициал.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.displayName,
    this.avatarUrl,
    this.radius = 20,
  });

  final String displayName;
  final String? avatarUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primaryContainer,
      backgroundImage: hasAvatar
          ? NetworkImage('${AuthService.baseUrl}$avatarUrl')
          : null,
      child: hasAvatar
          ? null
          : Text(
              initialOf(displayName),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                fontSize: radius * 0.8,
              ),
            ),
    );
  }
}
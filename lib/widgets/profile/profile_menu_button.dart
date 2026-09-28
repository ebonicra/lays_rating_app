import 'package:flutter/material.dart';

/// Меню (три точки) в AppBar профиля:
/// редактировать, обратная связь, удалить аккаунт.
class ProfileMenuButton extends StatelessWidget {
  const ProfileMenuButton({
    super.key,
    required this.onEdit,
    required this.onFeedback,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onFeedback;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = colorScheme.onSurface;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(maxWidth: 180),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
            break;
          case 'feedback':
            onFeedback();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          height: 45,
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: iconColor),
              SizedBox(width: 10),
              Text('Редактировать', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'feedback',
          height: 45,
          child: Row(
            children: [
              Icon(Icons.mail_outline_rounded, size: 18, color: iconColor),
              SizedBox(width: 10),
              Text('Обратная связь', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          height: 45,
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                size: 18,
                color: colorScheme.error,
              ),
              const SizedBox(width: 10),
              Text(
                'Удалить аккаунт',
                style: TextStyle(
                  color: colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
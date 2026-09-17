import 'package:flutter/material.dart';

/// Меню (три точки) в AppBar профиля: редактировать, удалить аккаунт.
class ProfileMenuButton extends StatelessWidget {
  const ProfileMenuButton({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(maxWidth: 200),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          height: 40,
          child: ListTile(
            leading: Icon(Icons.edit_outlined, size: 20),
            title: Text(
              'Редактировать',
              style: TextStyle(fontSize: 14),
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          height: 40,
          child: ListTile(
            leading: Icon(
              Icons.delete_outline,
              size: 20,
              color: colorScheme.error,
            ),
            title: Text(
              'Удалить аккаунт',
              style: TextStyle(
                color: colorScheme.error,
                fontSize: 14,
              ),
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
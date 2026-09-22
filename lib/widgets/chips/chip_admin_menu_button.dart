import 'package:flutter/material.dart';

/// Меню (три точки) с админскими действиями над чипсом:
class ChipAdminMenuButton extends StatelessWidget {
  const ChipAdminMenuButton({
    super.key,
    // required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  // final VoidCallback onAdd;
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
      constraints: const BoxConstraints(maxWidth: 170),
      onSelected: (value) {
        switch (value) {
          // case 'add':
          //   onAdd();
          //   break;
          case 'edit':
            onEdit();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        _buildItem(
          value: 'add',
          label: 'Добавить',
          icon: Icons.add_circle_outline,
          color: colorScheme.error,
        ),
        _buildItem(
          value: 'edit',
          label: 'Редактировать',
          icon: Icons.edit_outlined,
          color: colorScheme.error,
        ),
        _buildItem(
          value: 'delete',
          label: 'Удалить',
          icon: Icons.delete_outline,
          color: colorScheme.error,
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 25,
      child: ListTile(
        leading: Icon(icon, size: 20, color: color),
        title: Text(
          label,
          style: TextStyle(color: color, fontSize: 14),
        ),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
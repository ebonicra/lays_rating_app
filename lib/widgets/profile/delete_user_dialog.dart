import 'package:flutter/material.dart';

class DeleteUserDialog extends StatelessWidget {
  const DeleteUserDialog({super.key, required this.username});

  final String username;

  static Future<bool?> show(BuildContext context, String username) {
    return showDialog<bool>(
      context: context,
      builder: (_) => DeleteUserDialog(username: username),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        color: colorScheme.error,
      ),
      title: const Text(
        'Удалить пользователя?',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
      ),
      content: Text(
        'Пользователь @$username и все его данные будут удалены '
        'без возможности восстановления.',
        textAlign: TextAlign.center,
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
                child: const Text('Удалить'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
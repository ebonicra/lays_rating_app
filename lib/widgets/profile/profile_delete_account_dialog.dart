import 'package:flutter/material.dart';

// Диалог подтверждения удаления аккаунта.
class ProfileDeleteAccountDialog extends StatelessWidget {
  const ProfileDeleteAccountDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const ProfileDeleteAccountDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Удалить аккаунт?'),
      content: const Text(
        'Это действие нельзя отменить. '
        'Все оценки, комментарии и подписки будут удалены.',
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
              child: TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
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
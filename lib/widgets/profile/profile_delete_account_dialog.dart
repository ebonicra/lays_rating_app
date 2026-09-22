import 'package:flutter/material.dart';

/// Диалог подтверждения удаления аккаунта
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
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text(
        'Удалить аккаунт?',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'Все оценки, комментарии и подписки будут удалены. '
        'Это действие нельзя отменить.',
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
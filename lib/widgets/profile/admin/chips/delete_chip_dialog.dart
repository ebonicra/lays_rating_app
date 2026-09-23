import 'package:flutter/material.dart';

/// Диалог подтверждения удаления чипса.
class DeleteChipDialog extends StatelessWidget {
  const DeleteChipDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const DeleteChipDialog(),
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
        'Удалить чипс?',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'Все оценки и комментарии к этому чипсу будут удалены. '
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
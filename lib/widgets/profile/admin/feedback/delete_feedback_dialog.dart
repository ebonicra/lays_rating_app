import 'package:flutter/material.dart';

class DeleteFeedbackDialog extends StatelessWidget {
  const DeleteFeedbackDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const DeleteFeedbackDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Удалить сообщение?'),
      content: const Text('Действие нельзя отменить.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: colorScheme.error),
          child: const Text('Удалить'),
        ),
      ],
    );
  }
}
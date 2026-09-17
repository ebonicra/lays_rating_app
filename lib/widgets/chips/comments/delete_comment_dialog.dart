import 'package:flutter/material.dart';

/// Диалог подтверждения удаления комментария.
///
/// Возвращает `true` через [Navigator.pop], если пользователь подтвердил.
class DeleteCommentDialog extends StatelessWidget {
  const DeleteCommentDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const DeleteCommentDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Удалить комментарий?'),
      content: const Text('Это действие нельзя отменить'),
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
                style: TextButton.styleFrom(foregroundColor: colorScheme.error),
                child: const Text('Удалить'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
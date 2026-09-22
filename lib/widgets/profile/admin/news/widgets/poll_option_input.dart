import 'package:flutter/material.dart';

import 'poll_draft_option.dart';

/// Строка ввода одного варианта ответа: текст + кнопка удаления.
class PollOptionInput extends StatelessWidget {
  const PollOptionInput({
    super.key,
    required this.option,
    required this.canRemove,
    required this.onRemove,
  });

  final PollDraftOption option;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: option.textController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Вариант ответа',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          if (canRemove)
            IconButton(
              onPressed: onRemove,
              icon: Icon(Icons.close, color: colorScheme.error),
            ),
        ],
      ),
    );
  }
}
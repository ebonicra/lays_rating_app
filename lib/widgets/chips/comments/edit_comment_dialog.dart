import 'package:flutter/material.dart';

import 'package:lays_rating/models/chip_comment.dart';
import 'package:lays_rating/services/comments_service.dart';

/// Минималистичный шит для редактирования комментария.
///
/// Возвращает обновлённый [ChipCommentResponse] через [Navigator.pop]
/// или `null`, если отмена.
class EditCommentDialog extends StatefulWidget {
  const EditCommentDialog({
    super.key,
    required this.comment,
  });

  final ChipCommentResponse comment;

  static Future<ChipCommentResponse?> show(
    BuildContext context,
    ChipCommentResponse comment,
  ) {
    return showModalBottomSheet<ChipCommentResponse>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EditCommentDialog(comment: comment),
    );
  }

  @override
  State<EditCommentDialog> createState() => _EditCommentDialogState();
}

class _EditCommentDialogState extends State<EditCommentDialog> {
  late final TextEditingController _controller;
  bool _isSaving = false;

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.comment.text);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final updated = await CommentsService.updateComment(
        commentId: widget.comment.id,
        text: text,
      );

      if (!mounted) return;
      Navigator.pop(context, updated);
    } catch (e) {
      debugPrint('EditCommentDialog._save error: $e');
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось обновить'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        right: 0,
        top: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 6,
              minLines: 3,
              enabled: !_isSaving,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Исправь своё мнение...',
                hintStyle: const TextStyle(fontSize: 14),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: (_canSubmit && !_isSaving) ? _save : null,
            icon: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                : Icon(
                    Icons.check_rounded,
                    color: colorScheme.primary,
                  ),
            tooltip: 'Сохранить',
          ),
        ],
      ),
    );
  }
}
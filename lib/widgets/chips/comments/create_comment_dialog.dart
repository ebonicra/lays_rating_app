import 'package:flutter/material.dart';

/// Минималистичный шит для создания комментария к чипсу.
///
/// Возвращает текст через [Navigator.pop] или `null`, если отмена.
class CreateCommentDialog extends StatefulWidget {
  const CreateCommentDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const CreateCommentDialog(),
    );
  }

  @override
  State<CreateCommentDialog> createState() => _CreateCommentDialogState();
}

class _CreateCommentDialogState extends State<CreateCommentDialog> {
  final _controller = TextEditingController();

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.pop(context, text);
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
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Поделись своим мнением о чипсах...',
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
            onPressed: _canSubmit ? _submit : null,
            icon: Icon(
              Icons.send_rounded,
              color: colorScheme.primary,
            ),
            tooltip: 'Отправить',
          ),
        ],
      ),
    );
  }
}
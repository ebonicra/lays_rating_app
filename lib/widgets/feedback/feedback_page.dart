import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:lays_rating/models/feedback.dart';
import 'package:lays_rating/models/news_image.dart';
import 'package:lays_rating/services/feedback_service.dart';
import 'package:lays_rating/widgets/profile/admin/news/widgets/news_image_grid.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  static const int _maxImages = 10;

  late final TextEditingController _titleController;
  late final TextEditingController _textController;
  final List<NewsImage> _images = [];

  FeedbackType _type = FeedbackType.other;
  bool _isSending = false;

  bool get _canSave =>
      _titleController.text.trim().isNotEmpty &&
      _textController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  bool _isDirty() {
    return _titleController.text.trim().isNotEmpty ||
        _textController.text.trim().isNotEmpty ||
        _images.isNotEmpty;
  }

  Future<bool> _confirmExit() async {
    if (!_isDirty()) return true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.error,
        ),
        title: const Text(
          'Выйти без отправки?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Все несохранённые изменения будут потеряны.',
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Остаться'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  child: const Text('Выйти'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(
      imageQuality: 80,
      maxWidth: 1080,
      maxHeight: 1080,
    );

    if (picked.isEmpty || !mounted) return;

    setState(() {
      final remaining = _maxImages - _images.length;
      _images.addAll(
        picked.take(remaining).map((x) => NewsImage.local(x.path)),
      );
    });
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  Future<void> _send() async {
    if (!_canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Заполни заголовок и описание'),
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      // 1. Загружаем картинки
      final paths = <String>[];
      for (final img in _images) {
        if (img.isLocal) {
          final uploaded = await FeedbackService.uploadImage(img.localPath!);
          paths.add(uploaded);
        } else if (img.isRemote && img.remotePath != null) {
          paths.add(img.remotePath!);
        }
      }

      // 2. Отправляем feedback
      await FeedbackService.send(
        type: _type,
        title: _titleController.text.trim(),
        text: _textController.text.trim(),
        imagePaths: paths,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Спасибо! Сообщение отправлено'),
        ),
      );
    } catch (e) {
      debugPrint('FeedbackPage._send error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось отправить'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _confirmExit();
        if (shouldPop && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Обратная связь')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===== Тип =====
              const Text(
                'Тип сообщения',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              _buildTypeGrid(),

              const SizedBox(height: 14),

              // ===== Заголовок =====
              const Text(
                'Заголовок',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 120,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Кратко о чём сообщение...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  counterText: '',
                ),
              ),

              const SizedBox(height: 14),

              // ===== Текст =====
              const Text(
                'Описание',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _textController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 6,
                minLines: 4,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Подробнее...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ===== Картинки =====
              const Text(
                'Картинки (до 10-ти)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              NewsImageGrid(
                images: _images,
                onAdd: _pickImages,
                onRemove: _removeImage,
                maxImages: _maxImages,
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSending
                      ? null
                      : () async {
                          final shouldPop = await _confirmExit();
                          if (shouldPop && context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Отмена'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSending || !_canSave ? null : _send,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Отправить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Типы: сетка 2 в ряд =====
  Widget _buildTypeGrid() {
    final types = FeedbackType.values;

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 2.0;
        final itemWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: types.map((t) {
            final selected = t == _type;
            return SizedBox(
              width: itemWidth,
              child: _TypeButton(
                type: t,
                selected: selected,
                onTap: () => setState(() => _type = t),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ===== Кнопка типа =====
class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final FeedbackType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(
              type.emoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                type.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
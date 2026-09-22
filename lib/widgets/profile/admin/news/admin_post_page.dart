import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:lays_rating/services/admin_service.dart';
import 'package:lays_rating/widgets/profile/admin/news/widgets/news_image_grid.dart';

/// Страница создания обычного поста (текст + картинки).
class AdminPostPage extends StatefulWidget {
  const AdminPostPage({super.key});

  @override
  State<AdminPostPage> createState() => _AdminPostPageState();
}

class _AdminPostPageState extends State<AdminPostPage> {
  final _textController = TextEditingController();
  final List<String> _imagePaths = [];
  bool _isSaving = false;

  static const int _maxImages = 10;

  bool get _isDirty =>
      _textController.text.trim().isNotEmpty || _imagePaths.isNotEmpty;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      imageQuality: 80,
      maxWidth: 1080,
      maxHeight: 1080,
    );

    if (images.isEmpty || !mounted) return;

    setState(() {
      final remaining = _maxImages - _imagePaths.length;
      final toAdd = images.take(remaining).map((img) => img.path);
      _imagePaths.addAll(toAdd);
    });
  }

  void _removeImage(int index) {
    setState(() => _imagePaths.removeAt(index));
  }

  Future<bool> _confirmExit() async {
    if (!_isDirty) return true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Выйти без сохранения?'),
        content: const Text('Изменения не сохранятся.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Остаться'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    try {
      // Загружаем картинки
      final chipsData = <Map<String, dynamic>>[];
      for (final path in _imagePaths) {
        final imagePath = await AdminService.uploadNewsImage(path);
        chipsData.add({'image_path': imagePath});
      }

      await AdminService.createNews(
        eventType: 'admin_post',
        text: _textController.text.trim(),
        extraData: chipsData.isNotEmpty ? {'chips': chipsData} : null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Новость создана')
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('AdminPostPage._save error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось создать новость')
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
        appBar: AppBar(title: const Text('Обычный пост')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Картинки (до 10-ти)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              NewsImageGrid(
                imagePaths: _imagePaths,
                onAdd: _pickImages,
                onRemove: _removeImage,
                maxImages: _maxImages,
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Текст новости',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _textController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Тыры-пыры',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving
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
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Сохранить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
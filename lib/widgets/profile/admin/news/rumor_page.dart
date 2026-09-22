import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:lays_rating/services/admin_service.dart';
import 'package:lays_rating/widgets/profile/admin/news/widgets/news_image_grid.dart';

/// Страница создания слуха (картинки + источник + текст).
class RumorPage extends StatefulWidget {
  const RumorPage({super.key});

  @override
  State<RumorPage> createState() => _RumorPageState();
}

class _RumorPageState extends State<RumorPage> {
  static const int _maxImages = 10;

  static const List<String> _sources = [
    '',
    "Анонс от Lay's",
    'Замечено в магазине',
  ];

  final _textController = TextEditingController();
  final List<String> _imagePaths = [];
  String _source = '';
  bool _isSaving = false;

  bool get _isDirty =>
      _textController.text.trim().isNotEmpty ||
      _imagePaths.isNotEmpty ||
      _source.isNotEmpty;

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
      _imagePaths.addAll(images.take(remaining).map((img) => img.path));
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
    if (_imagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Загрузите хотя бы одну картинку')
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final chipsData = <Map<String, dynamic>>[];
      for (final path in _imagePaths) {
        final imagePath = await AdminService.uploadNewsImage(path);
        chipsData.add({'image_path': imagePath});
      }

      await AdminService.createNews(
        eventType: 'rumor',
        text: _textController.text.trim(),
        extraData: {
          'chips': chipsData,
          'source': _source,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Слух создан')
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('RumorPage._save error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось создать слух')
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
        appBar: AppBar(title: const Text('Слухи')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Картинки (До 10-ти)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              NewsImageGrid(
                imagePaths: _imagePaths,
                onAdd: _pickImages,
                onRemove: _removeImage,
                maxImages: _maxImages,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _source,
                decoration: InputDecoration(
                  labelText: 'Источник',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                items: _sources
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.isEmpty ? 'Не указано' : s),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _source = v ?? ''),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _textController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Что там по слухам?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
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
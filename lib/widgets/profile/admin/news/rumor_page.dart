import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:lays_rating/models/news_image.dart';
import 'package:lays_rating/models/news_item.dart';
import 'package:lays_rating/services/admin_service.dart';
import 'package:lays_rating/widgets/profile/admin/news/widgets/news_image_grid.dart';

/// Страница создания / редактирования слуха (картинки + источник + текст).
class RumorPage extends StatefulWidget {
  const RumorPage({
    super.key,
    this.initialNews,
  });

  final NewsItem? initialNews;

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

  late final TextEditingController _textController;
  final List<NewsImage> _images = [];
  String _source = '';
  bool _isSaving = false;

  bool get _isEditing => widget.initialNews != null;

  @override
  void initState() {
    super.initState();

    final news = widget.initialNews;
    _textController = TextEditingController(text: news?.text ?? '');

    if (news != null) {
      final extra = news.extraData;

      // Источник
      final src = extra?['source'] as String?;
      if (src != null && _sources.contains(src)) {
        _source = src;
      }

      // Картинки
      final chips = extra?['chips'] as List?;
      if (chips != null) {
        for (final c in chips) {
          if (c is Map) {
            final path = c['image_path'] as String?;
            if (path != null && path.isNotEmpty) {
              _images.add(NewsImage.remote(path));
            }
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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
        picked.take(remaining).map((img) => NewsImage.local(img.path)),
      );
    });
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  bool _isDirty() {
    final news = widget.initialNews;

    if (news == null) {
      return _textController.text.trim().isNotEmpty ||
          _images.isNotEmpty ||
          _source.isNotEmpty;
    }

    final originalText = (news.text ?? '').trim();
    if (_textController.text.trim() != originalText) return true;

    final originalSource = (news.extraData?['source'] as String?) ?? '';
    if (_source != originalSource) return true;

    if (_images.any((i) => i.isLocal)) return true;

    final originalCount =
        (news.extraData?['chips'] as List?)?.length ?? 0;
    return _images.length != originalCount;
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
          'Выйти без сохранения?',
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

  Future<void> _save() async {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Загрузите хотя бы одну картинку'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final chipsData = <Map<String, dynamic>>[];

      for (final image in _images) {
        if (image.isRemote) {
          chipsData.add({'image_path': image.remotePath});
        } else {
          final uploaded =
              await AdminService.uploadNewsImage(image.localPath!);
          chipsData.add({'image_path': uploaded});
        }
      }

      final extraData = <String, dynamic>{
        'chips': chipsData,
        'source': _source,
      };

      if (_isEditing) {
        await AdminService.updateNews(
          newsId: widget.initialNews!.id,
          text: _textController.text.trim(),
          extraData: extraData,
        );
      } else {
        await AdminService.createNews(
          eventType: 'rumor',
          text: _textController.text.trim(),
          extraData: extraData,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(_isEditing ? 'Сохранено' : 'Слух создан'),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('RumorPage._save error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            _isEditing ? 'Не удалось сохранить' : 'Не удалось создать слух',
          ),
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
        appBar: AppBar(
          title: Text(_isEditing ? 'Редактировать слух' : 'Слухи'),
        ),
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
                images: _images,
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
                      : Text(_isEditing ? 'Сохранить' : 'Создать'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
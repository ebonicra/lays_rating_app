import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:lays_rating/models/news_image.dart';
import 'package:lays_rating/models/news_item.dart';
import 'package:lays_rating/services/admin_service.dart';
import 'package:lays_rating/widgets/profile/admin/news/widgets/news_image_grid.dart';

/// Страница создания / редактирования обычного поста (текст + картинки).
class AdminPostPage extends StatefulWidget {
  const AdminPostPage({
    super.key,
    this.initialNews,
  });

  final NewsItem? initialNews;

  @override
  State<AdminPostPage> createState() => _AdminPostPageState();
}

class _AdminPostPageState extends State<AdminPostPage> {
  static const int _maxImages = 10;

  late final TextEditingController _textController;
  final List<NewsImage> _images = [];
  bool _isSaving = false;

  bool get _isEditing => widget.initialNews != null;

  bool get _canSave =>
      _textController.text.trim().isNotEmpty || _images.isNotEmpty;

  @override
  void initState() {
    super.initState();
    final news = widget.initialNews;

    _textController = TextEditingController(text: news?.text ?? '');

    // Загружаем существующие картинки (только remote)
    if (news != null) {
      final chips = news.extraData?['chips'] as List?;
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

    // Создание — dirty, если что-то есть
    if (news == null) {
      return _textController.text.trim().isNotEmpty || _images.isNotEmpty;
    }

    // Редактирование
    final originalText = (news.text ?? '').trim();
    if (_textController.text.trim() != originalText) return true;

    // Если появились новые локальные картинки — dirty
    if (_images.any((i) => i.isLocal)) return true;

    // Если количество серверных картинок изменилось — dirty
    final originalCount = (news.extraData?['chips'] as List?)?.length ?? 0;
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
    if (!_canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Добавьте текст или картинку'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final chipsData = <Map<String, dynamic>>[];

      // Обрабатываем картинки: локальные — загружаем, серверные — как есть
      for (final image in _images) {
        if (image.isRemote) {
          chipsData.add({'image_path': image.remotePath});
        } else {
          final uploaded =
              await AdminService.uploadNewsImage(image.localPath!);
          chipsData.add({'image_path': uploaded});
        }
      }

      final extraData = chipsData.isNotEmpty ? {'chips': chipsData} : null;

      if (_isEditing) {
        await AdminService.updateNews(
          newsId: widget.initialNews!.id,
          text: _textController.text.trim(),
          extraData: extraData,
        );
      } else {
        await AdminService.createNews(
          eventType: 'admin_post',
          text: _textController.text.trim(),
          extraData: extraData,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(_isEditing ? 'Сохранено' : 'Новость создана'),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('AdminPostPage._save error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            _isEditing ? 'Не удалось сохранить' : 'Не удалось создать новость',
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
          title: Text(_isEditing ? 'Редактировать пост' : 'Обычный пост'),
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
              const SizedBox(height: 20),
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
                  hintText: 'Текст новости...',
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
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:lays_rating/models/news_image.dart';
import 'package:lays_rating/models/news_item.dart';
import 'package:lays_rating/services/admin_service.dart';
import 'package:lays_rating/widgets/profile/admin/news/widgets/news_image_grid.dart';
import 'package:lays_rating/widgets/profile/admin/news/widgets/poll_draft_option.dart';
import 'package:lays_rating/widgets/profile/admin/news/widgets/poll_option_input.dart';

/// Страница создания / редактирования опроса
/// (картинки + вопрос + варианты + текст).
class PollPage extends StatefulWidget {
  const PollPage({
    super.key,
    this.initialNews,
  });

  final NewsItem? initialNews;

  @override
  State<PollPage> createState() => _PollPageState();
}

class _PollPageState extends State<PollPage> {
  static const int _maxImages = 10;
  static const int _maxOptions = 10;
  static const int _minOptions = 2;

  late final TextEditingController _questionController;
  late final TextEditingController _textController;
  final List<NewsImage> _images = [];
  final List<PollDraftOption> _options = [];

  bool _isSaving = false;

  bool get _isEditing => widget.initialNews != null;

  @override
  void initState() {
    super.initState();

    final news = widget.initialNews;

    // === Текст и вопрос ===
    _textController = TextEditingController(text: news?.text ?? '');
    _questionController = TextEditingController(
      text: (news?.extraData?['question'] as String?) ?? '',
    );

    // === Картинки и варианты ===
    if (news != null) {
      final extra = news.extraData;

      // Картинки — по индексу в option. Картинки у опроса привязаны
      // к вариантам по позиции, отдельного списка нет.
      final options = extra?['options'] as List?;
      if (options != null) {
        for (final o in options) {
          if (o is Map) {
            final text = o['text'] as String? ?? '';
            final option = PollDraftOption()..textController.text = text;
            _options.add(option);

            final imgPath = o['image_path'] as String?;
            if (imgPath != null && imgPath.isNotEmpty) {
              _images.add(NewsImage.remote(imgPath));
            }
          }
        }
      }
    }

    // Если вариантов нет — добавляем минимум (пустые)
    if (_options.isEmpty) {
      _options.add(PollDraftOption());
      _options.add(PollDraftOption());
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _textController.dispose();
    for (final option in _options) {
      option.dispose();
    }
    super.dispose();
  }

  // ===== КАРТИНКИ =====

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

  // ===== ВАРИАНТЫ =====

  void _addOption() {
    if (_options.length >= _maxOptions) return;
    setState(() => _options.add(PollDraftOption()));
  }

  void _removeOption(int index) {
    if (_options.length <= _minOptions) return;

    setState(() {
      _options[index].dispose();
      _options.removeAt(index);

      // Если картинки были привязаны к варианту по индексу —
      // удаляем соответствующую (если есть)
      if (index < _images.length) {
        _images.removeAt(index);
      }
    });
  }

  // ===== DIRTY =====

  bool _isDirty() {
    final news = widget.initialNews;

    if (news == null) {
      return _questionController.text.trim().isNotEmpty ||
          _textController.text.trim().isNotEmpty ||
          _images.isNotEmpty ||
          _options.any((o) => o.textController.text.trim().isNotEmpty);
    }

    final originalQuestion =
        (news.extraData?['question'] as String?) ?? '';
    if (_questionController.text.trim() != originalQuestion.trim()) {
      return true;
    }

    final originalText = (news.text ?? '').trim();
    if (_textController.text.trim() != originalText) return true;

    if (_images.any((i) => i.isLocal)) return true;

    // Сравнение вариантов
    final originalOptions = (news.extraData?['options'] as List?) ?? [];
    final currentFilled = _options
        .where((o) => o.textController.text.trim().isNotEmpty)
        .toList();

    if (currentFilled.length != originalOptions.length) return true;

    for (var i = 0; i < currentFilled.length; i++) {
      final originalText =
          (originalOptions[i] as Map)['text'] as String? ?? '';
      if (currentFilled[i].textController.text.trim() != originalText.trim()) {
        return true;
      }
    }

    return false;
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

  // ===== СОХРАНЕНИЕ =====

  Future<void> _save() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      _showError('Введите вопрос');
      return;
    }

    final filledOptions = _options
        .where((o) => o.textController.text.trim().isNotEmpty)
        .toList();

    if (filledOptions.length < _minOptions) {
      _showError('Заполните минимум $_minOptions варианта');
      return;
    }

    // Если картинки есть — их количество должно совпадать
    if (_images.isNotEmpty && _images.length != filledOptions.length) {
      _showError(
        'Картинок: ${_images.length}, '
        'вариантов: ${filledOptions.length}. Должно совпадать.',
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Обрабатываем картинки: локальные — грузим, серверные — как есть
      final uploadedPaths = <String>[];
      for (final image in _images) {
        if (image.isRemote) {
          uploadedPaths.add(image.remotePath!);
        } else {
          final uploaded =
              await AdminService.uploadNewsImage(image.localPath!);
          uploadedPaths.add(uploaded);
        }
      }

      // Раскладываем по вариантам по индексу
      final optionsData = <Map<String, dynamic>>[];
      for (var i = 0; i < filledOptions.length; i++) {
        optionsData.add({
          'text': filledOptions[i].textController.text.trim(),
          if (i < uploadedPaths.length) 'image_path': uploadedPaths[i],
        });
      }

      final extraData = <String, dynamic>{
        'question': question,
        'options': optionsData,
      };

      if (_isEditing) {
        await AdminService.updateNews(
          newsId: widget.initialNews!.id,
          text: _textController.text.trim(),
          extraData: extraData,
        );
      } else {
        await AdminService.createNews(
          eventType: 'poll',
          text: _textController.text.trim(),
          extraData: extraData,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(_isEditing ? 'Сохранено' : 'Опрос создан'),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('PollPage._save error: $e');
      if (!mounted) return;
      _showError(_isEditing ? 'Не удалось сохранить' : 'Не удалось создать опрос');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ===== HELPERS =====

  Widget _buildImageCountHint(ThemeData theme) {
    final filledCount = _options
        .where((o) => o.textController.text.trim().isNotEmpty)
        .length;

    if (_images.isEmpty) {
      return Text(
        'Картинки необязательны',
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    final isValid = _images.length == filledCount;

    return Text(
      'Картинок: ${_images.length}, вариантов: $filledCount',
      style: TextStyle(
        fontSize: 12,
        color: isValid
            ? theme.colorScheme.onSurfaceVariant
            : theme.colorScheme.error,
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  // ===== BUILD =====

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          title: Text(_isEditing ? 'Редактировать опрос' : 'Опрос'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // === Картинки ===
              const Text(
                'Картинки',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              NewsImageGrid(
                images: _images,
                onAdd: _pickImages,
                onRemove: _removeImage,
                maxImages: _maxImages,
              ),
              const SizedBox(height: 4),
              _buildImageCountHint(theme),
              const SizedBox(height: 16),

              // === Вопрос ===
              TextField(
                controller: _questionController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Вопрос опроса',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // === Варианты ===
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Варианты ответа',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '${_options.length}/$_maxOptions',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                return PollOptionInput(
                  key: ObjectKey(option),
                  option: option,
                  canRemove: _options.length > _minOptions,
                  onRemove: () => _removeOption(index),
                );
              }),
              if (_options.length < _maxOptions)
                OutlinedButton.icon(
                  onPressed: _addOption,
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить вариант'),
                ),
              const SizedBox(height: 16),

              // === Текст новости ===
              TextField(
                controller: _textController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Текст новости',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
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
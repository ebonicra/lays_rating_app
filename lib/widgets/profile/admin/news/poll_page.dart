import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:lays_rating/services/admin_service.dart';
import 'package:lays_rating/widgets/profile/admin/news/widgets/news_image_grid.dart';
import 'package:lays_rating/widgets/profile/admin/news/widgets/poll_draft_option.dart';
import 'package:lays_rating/widgets/profile/admin/news/widgets/poll_option_input.dart';

/// Страница создания опроса (картинки + вопрос + варианты + текст).
class PollPage extends StatefulWidget {
  const PollPage({super.key});

  @override
  State<PollPage> createState() => _PollPageState();
}

class _PollPageState extends State<PollPage> {
  static const int _maxImages = 10;
  static const int _maxOptions = 10;
  static const int _minOptions = 2;

  final _questionController = TextEditingController();
  final _textController = TextEditingController();
  final List<String> _imagePaths = [];
  final List<PollDraftOption> _options = [];

  bool _isSaving = false;

  bool get _isDirty =>
      _questionController.text.trim().isNotEmpty ||
      _textController.text.trim().isNotEmpty ||
      _imagePaths.isNotEmpty ||
      _options.any((o) => o.textController.text.trim().isNotEmpty);

  @override
  void initState() {
    super.initState();
    // По умолчанию — два пустых варианта
    _options.add(PollDraftOption());
    _options.add(PollDraftOption());
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

  void _addOption() {
    if (_options.length >= _maxOptions) return;
    setState(() => _options.add(PollDraftOption()));
  }

  void _removeOption(int index) {
    if (_options.length <= _minOptions) return;
    setState(() {
      _options[index].dispose();
      _options.removeAt(index);
    });
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

    // Проверка: если картинки есть — их количество должно совпадать
    if (_imagePaths.isNotEmpty &&
        _imagePaths.length != filledOptions.length) {
      _showError(
        'Картинок: ${_imagePaths.length}, '
        'вариантов: ${filledOptions.length}. Должно совпадать.',
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Загружаем картинки
      final uploadedPaths = <String>[];
      for (final path in _imagePaths) {
        final imagePath = await AdminService.uploadNewsImage(path);
        uploadedPaths.add(imagePath);
      }

      // Раскладываем по вариантам по индексу
      final optionsData = <Map<String, dynamic>>[];
      for (var i = 0; i < filledOptions.length; i++) {
        optionsData.add({
          'text': filledOptions[i].textController.text.trim(),
          if (i < uploadedPaths.length) 'image_path': uploadedPaths[i],
        });
      }

      await AdminService.createNews(
        eventType: 'poll',
        text: _textController.text.trim(),
        extraData: {
          'question': question,
          'options': optionsData,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Опрос создан')
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('PollPage._save error: $e');
      if (!mounted) return;
      _showError('Не удалось создать опрос');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildImageCountHint(ThemeData theme) {
    final filledCount = _options
        .where((o) => o.textController.text.trim().isNotEmpty)
        .length;

    if (_imagePaths.isEmpty) {
      return Text(
        'Картинки необязательны',
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    final isValid = _imagePaths.length == filledCount;

    return Text(
      'Картинок: ${_imagePaths.length}, вариантов: $filledCount',
      style: TextStyle(
        fontSize: 12,
        color: isValid ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.error,
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message)
      ),
    );
  }

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
        appBar: AppBar(title: const Text('Опрос')),
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
                imagePaths: _imagePaths,
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
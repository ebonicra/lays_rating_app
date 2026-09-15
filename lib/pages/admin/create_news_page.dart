import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:lays_rating/services/admin_service.dart';

class CreateNewsPage extends StatefulWidget {
  const CreateNewsPage({super.key});

  @override
  State<CreateNewsPage> createState() => _CreateNewsPageState();
}

class _CreateNewsPageState extends State<CreateNewsPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _pollQuestionController = TextEditingController(); // ← для вопроса опроса
  final List<_RumorChip> _chips = [];
  final List<_PollOption> _pollOptions = [];
  String _newsType = 'admin_post';
  String _source = '';

  static const int _maxChips = 4;
  static const int _maxPollOptions = 4;
  static const int _minPollOptions = 2;

  @override
  void initState() {
    super.initState();
    // По умолчанию 2 варианта опроса
    _pollOptions.add(_PollOption());
    _pollOptions.add(_PollOption());
  }


  @override
  void dispose() {
    _textController.dispose();
    _pollQuestionController.dispose();
    super.dispose();
  }

  void _addPollOption() {
    if (_pollOptions.length >= _maxPollOptions) return;
    setState(() {
      _pollOptions.add(_PollOption());
    });
  }

  void _removePollOption(int index) {
    if (_pollOptions.length <= _minPollOptions) return;
    setState(() {
      _pollOptions.removeAt(index);
    });
  }

  Future<void> _pickImageForSlot(int index) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1080,
      maxHeight: 1080,
    );

    if (image != null) {
      setState(() {
        // Если слот ещё не существует — создаём
        while (_chips.length <= index) {
          _chips.add(_RumorChip());
        }
        _chips[index].localImagePath = image.path;
      });
    }
  }

  void _removeChipImage(int index) {
    setState(() {
      _chips[index].localImagePath = null;
      // Убираем пустые слоты с конца
      while (_chips.isNotEmpty && _chips.last.localImagePath == null) {
        _chips.removeLast();
      }
    });
  }

  Future<void> _createNews() async {
    // Проверка: хотя бы одна картинка для слухов
    if (_newsType == 'rumor') {
      final hasImage = _chips.any((chip) => chip.localImagePath != null);
      if (!hasImage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Загрузите хотя бы одну картинку')),
        );
        return;
      }
    }

    if (_newsType == 'poll') {
      if (_pollQuestionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Введите вопрос')),
        );
        return;
      }
      
      final filledOptions = _pollOptions.where(
        (o) => o.textController.text.trim().isNotEmpty,
      ).toList();
      
      if (filledOptions.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Заполните минимум 2 варианта')),
        );
        return;
      }
    }

    try {
      // Загружаем картинки для новости (слухи/обычный пост)
      final chipsData = [];
      for (final chip in _chips) {
        if (chip.localImagePath != null) {
          final imagePath = await AdminService.uploadNewsImage(chip.localImagePath!);
          chipsData.add({'image_path': imagePath});
        }
      }

      // Формируем extra_data
      Map<String, dynamic>? extraData;

      if (_newsType == 'rumor') {
        extraData = {
          'chips': chipsData,
          'source': _source,
        };
      } else if (_newsType == 'poll') {
        // Загружаем картинки для вариантов опроса
        final optionsData = [];
        for (final option in _pollOptions) {
          if (option.textController.text.trim().isEmpty) continue;
          
          String? imagePath;
          if (option.localImagePath != null) {
            imagePath = await AdminService.uploadNewsImage(option.localImagePath!);
          }
          
          optionsData.add({
            'text': option.textController.text.trim(),
            'image_path': imagePath,
          });
        }
        
        extraData = {
          'question': _pollQuestionController.text.trim(),
          'options': optionsData,
        };
      } else if (chipsData.isNotEmpty) {
        extraData = {'chips': chipsData};
      }

      await AdminService.createNews(
        eventType: _newsType,
        text: _textController.text.trim(),
        extraData: extraData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Новость создана')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать новость'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Тип новости
            DropdownButtonFormField<String>(
              value: _newsType,
              decoration: InputDecoration(
                labelText: 'Тип новости',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.15),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: const [
                DropdownMenuItem(value: 'admin_post', child: Text('Обычный пост')),
                DropdownMenuItem(value: 'rumor', child: Text('Слухи')),
                DropdownMenuItem(value: 'poll', child: Text('Опрос')),
              ],
              onChanged: (v) => setState(() => _newsType = v!),
            ),
            const SizedBox(height: 20),

            // Если слухи — картинки
            // const Text(
            //   'Картинки вкусов (от 1 до 4-х)',
            //   style: TextStyle(
            //     fontWeight: FontWeight.bold,
            //     fontSize: 16,
            //   ),
            // ),
            // const SizedBox(height: 8),

            // 4 слота для картинок
            // Row(
            //   children: List.generate(_maxChips, (index) {
            //     final hasImage = index < _chips.length && _chips[index].localImagePath != null;
                
            //     return Expanded(
            //       child: Padding(
            //         padding: const EdgeInsets.symmetric(horizontal: 2),
            //         child: _ImageSlot(
            //           imagePath: hasImage ? _chips[index].localImagePath : null,
            //           onTap: () => _pickImageForSlot(index),
            //           onRemove: hasImage ? () => _removeChipImage(index) : null,
            //         ),
            //       ),
            //     );
            //   }),
            // ),
            // const SizedBox(height: 12),

            if (_newsType != 'poll') ...[
              const Text(
                'Картинки (от 1 до 4-х)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(_maxChips, (index) {
                  final hasImage = index < _chips.length && _chips[index].localImagePath != null;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _ImageSlot(
                        imagePath: hasImage ? _chips[index].localImagePath : null,
                        onTap: () => _pickImageForSlot(index),
                        onRemove: hasImage ? () => _removeChipImage(index) : null,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
            ],

              // Источник
            if (_newsType == 'rumor') ...[
              DropdownButtonFormField<String>(
                value: _source,
                decoration: InputDecoration(
                  labelText: 'Источник',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('Не указано'),
                  ),
                  const DropdownMenuItem(
                    value: 'Анонс от Lay\'s',
                    child: Text('Анонс от Lay\'s'),
                  ),
                  const DropdownMenuItem(
                    value: 'Замечено в магазине',
                    child: Text('Замечено в магазине'),
                  ),
                ],
                onChanged: (v) => setState(() => _source = v ?? ''),
              ),
              const SizedBox(height: 10),
            ],

            if (_newsType == 'poll') ...[
              // Вопрос
              TextField(
                controller: _pollQuestionController,
                decoration: InputDecoration(
                  labelText: 'Вопрос опроса',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Заголовок вариантов
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Варианты ответа',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '${_pollOptions.length}/$_maxPollOptions',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Список вариантов
              ..._pollOptions.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                return _PollOptionInput(
                  key: ValueKey(index),
                  option: option,
                  canRemove: _pollOptions.length > _minPollOptions,
                  onRemove: () => _removePollOption(index),
                );
              }),

              const SizedBox(height: 8),
              
              // Кнопка добавить вариант
              if (_pollOptions.length < _maxPollOptions)
                OutlinedButton.icon(
                  onPressed: _addPollOption,
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить вариант'),
                ),
              const SizedBox(height: 12),
            ],


            // Текст
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Текст новости',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _createNews,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Создать новость'),
        ),
      ),
    );
  }
}


class _ImageSlot extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _ImageSlot({
    required this.imagePath,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: imagePath == null ? onTap : null, // тап только на пустой слот
      child: AspectRatio(
        aspectRatio: 1, // квадратные
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: imagePath != null
                  ? theme.colorScheme.primary.withOpacity(0.3)
                  : theme.colorScheme.outlineVariant,
              width: 1.5,
            ),
          ),
          child: imagePath != null
              ? Stack(
                  children: [
                    // Картинка
                    ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.file(
                        File(imagePath!),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Крестик удаления
                    if (onRemove != null)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: onRemove,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.6),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              : Icon(
                  Icons.add_photo_alternate_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 28,
                ),
        ),
      ),
    );
  }
}

class _RumorChip {
  String? localImagePath;

  _RumorChip({this.localImagePath});
}


class _PollOption {
  final TextEditingController textController = TextEditingController();
  String? localImagePath;

  _PollOption();

  void dispose() {
    textController.dispose();
  }
}

class _PollOptionInput extends StatefulWidget {
  final _PollOption option;
  final bool canRemove;
  final VoidCallback onRemove;

  const _PollOptionInput({
    super.key,
    required this.option,
    required this.canRemove,
    required this.onRemove,
  });

  @override
  State<_PollOptionInput> createState() => _PollOptionInputState();
}

class _PollOptionInputState extends State<_PollOptionInput> {
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (image != null) {
      setState(() {
        widget.option.localImagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Картинка варианта
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.option.localImagePath != null
                      ? theme.colorScheme.primary.withOpacity(0.3)
                      : theme.colorScheme.outlineVariant,
                  width: 1.5,
                ),
              ),
              child: widget.option.localImagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.file(
                        File(widget.option.localImagePath!),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.add_photo_alternate_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(width: 8),

          // Текст варианта
          Expanded(
            child: TextField(
              controller: widget.option.textController,
              decoration: InputDecoration(
                hintText: 'Вариант ответа',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
              ),
            ),
          ),

          // Удалить
          if (widget.canRemove)
            IconButton(
              onPressed: widget.onRemove,
              icon: const Icon(Icons.close, color: Colors.red),
            ),
        ],
      ),
    );
  }
}
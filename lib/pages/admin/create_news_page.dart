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
  final List<_RumorChip> _chips = [];
  String _newsType = 'admin_post';
  String _source = '';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addChip() {
    setState(() {
      _chips.add(_RumorChip());
    });
  }

  void _removeChip(int index) {
    setState(() {
      _chips.removeAt(index);
    });
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
              ],
              onChanged: (v) => setState(() => _newsType = v!),
            ),
            const SizedBox(height: 50),

            // Если слухи — добавляем чипсы
            if (_newsType == 'rumor') ...[
              const Text(
                'Чипсы в слухах:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),

              // Список чипсов
              ..._chips.asMap().entries.map((entry) {
                final index = entry.key;
                final chip = entry.value;
                return _ChipInput(
                  key: ValueKey(index),
                  chip: chip,
                  onRemove: () => _removeChip(index),
                );
              }),

              // const SizedBox(height: 4),
              OutlinedButton.icon(
                onPressed: _addChip,
                icon: const Icon(Icons.add),
                label: const Text('Добавить чипсы'),
              ),
              const SizedBox(height: 12),

              // Источник
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
              const SizedBox(height: 4),
            ],

            // Текст
            TextField(
              controller: _textController,
              maxLines: 3,
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
            // Убрали кнопку отсюда!
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


  // В create_news_page.dart:

  Future<void> _createNews() async {
    try {
      print('1. Начинаю создание новости');
      
      // Загружаем картинки чипсов (если есть)
      final chipsData = [];
      for (final chip in _chips) {
        String? imagePath;
        if (chip.localImagePath != null) {
          imagePath = await AdminService.uploadNewsImage(chip.localImagePath!);
          print('Картинка загружена: $imagePath');
        }
        chipsData.add({
          'name': chip.name,
          'image_path': imagePath,
        });
      }
      print('2. Чипсы: $chipsData');

      // Формируем данные новости
      final extraData = _newsType == 'rumor'
          ? {
              'chips': chipsData,
              'source': _source,
            }
          : null;
      print('3. Extra data: $extraData');

      await AdminService.createNews(
        eventType: _newsType,
        text: _textController.text.trim(),
        extraData: extraData,
      );
      print('4. Новость создана!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Новость создана')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('❌ Ошибка: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка: $e')),
        );
      }
    }
  }
}

class _RumorChip {
  String name;
  String? localImagePath; // ← локальный путь к выбранной картинке

  _RumorChip({
    this.name = '',
    this.localImagePath,
  });
}
class _ChipInput extends StatefulWidget {
  final _RumorChip chip;
  final VoidCallback onRemove;

  const _ChipInput({
    super.key,
    required this.chip,
    required this.onRemove,
  });

  @override
  State<_ChipInput> createState() => _ChipInputState();
}

class _ChipInputState extends State<_ChipInput> {
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
        widget.chip.localImagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          // Название
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Название вкуса',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (v) => widget.chip.name = v,
            ),
          ),
          const SizedBox(width: 4),

          // Кнопка выбора картинки
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              child: widget.chip.localImagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(widget.chip.localImagePath!),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.image_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
            ),
          ),

          // Кнопка удаления
          IconButton(
            onPressed: widget.onRemove,
            icon: const Icon(Icons.close, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
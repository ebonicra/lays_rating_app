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

  static const int _maxChips = 4;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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

    try {
      // Загружаем картинки (для ВСЕХ типов)
      final chipsData = [];
      for (final chip in _chips) {
        if (chip.localImagePath != null) {
          final imagePath = await AdminService.uploadNewsImage(chip.localImagePath!);
          chipsData.add({'image_path': imagePath});
        }
      }
      print('Загружено картинок: ${chipsData.length}');

      // Формируем extra_data
      Map<String, dynamic>? extraData;
      
      if (_newsType == 'rumor') {
        extraData = {
          'chips': chipsData,
          'source': _source,
        };
      } else if (chipsData.isNotEmpty) {
        // ← Для обычного поста тоже сохраняем картинки
        extraData = {
          'chips': chipsData,
        };
      }
      
      print('extraData: $extraData');

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
      print('❌ Ошибка: $e');
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
              ],
              onChanged: (v) => setState(() => _newsType = v!),
            ),
            const SizedBox(height: 20),

            // Если слухи — картинки
            const Text(
              'Картинки вкусов (от 1 до 4-х)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),

            // 4 слота для картинок
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
// class _ChipInput extends StatefulWidget {
//   final _RumorChip chip;
//   final VoidCallback onRemove;

//   const _ChipInput({
//     super.key,
//     required this.chip,
//     required this.onRemove,
//   });

//   @override
//   State<_ChipInput> createState() => _ChipInputState();
// }

// class _ChipInputState extends State<_ChipInput> {
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final image = await picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 80,
//       maxWidth: 800,
//       maxHeight: 800,
//     );

//     if (image != null) {
//       setState(() {
//         widget.chip.localImagePath = image.path;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 2),
//       child: Row(
//         children: [
//           // Название
//           Expanded(
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Название вкуса',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide(
//                     color: theme.colorScheme.outlineVariant,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide(
//                     color: theme.colorScheme.primary,
//                     width: 2,
//                   ),
//                 ),
//               ),
//               onChanged: (v) => widget.chip.name = v,
//             ),
//           ),
//           const SizedBox(width: 4),

//           // Кнопка выбора картинки
//           GestureDetector(
//             onTap: _pickImage,
//             child: Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(
//                   color: theme.colorScheme.outlineVariant,
//                 ),
//               ),
//               child: widget.chip.localImagePath != null
//                   ? ClipRRect(
//                       borderRadius: BorderRadius.circular(16),
//                       child: Image.file(
//                         File(widget.chip.localImagePath!),
//                         width: 60,
//                         height: 60,
//                         fit: BoxFit.cover,
//                       ),
//                     )
//                   : Icon(
//                       Icons.image_outlined,
//                       color: theme.colorScheme.onSurfaceVariant,
//                     ),
//             ),
//           ),

//           // Кнопка удаления
//           IconButton(
//             onPressed: widget.onRemove,
//             icon: const Icon(Icons.close, color: Colors.red),
//           ),
//         ],
//       ),
//     );
//   }
// }
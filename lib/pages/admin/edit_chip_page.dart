import 'package:flutter/material.dart';
import 'package:lays_rating/models/chip.dart';
import '../../services/chip_service.dart';

class EditChipPage extends StatefulWidget {
  final LaysChip? chip;

  const EditChipPage({
    super.key,
    this.chip,
  });

  @override
  State<EditChipPage> createState() => _EditChipPageState();
}

class _EditChipPageState extends State<EditChipPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _imagePathController;
  late TextEditingController _collectionController;
  late TextEditingController _countryController;
  late TextEditingController _releaseYearController;
  late TextEditingController _discontinuedYearController;
  
  String? _selectedCategory;
  bool _available = true;
  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final chip = widget.chip;

    if (chip != null) {
      _nameController = TextEditingController(text: chip.name);
      _descriptionController = TextEditingController(text: chip.description);
      _imagePathController = TextEditingController(text: chip.imagePath);
      _collectionController = TextEditingController(text: chip.collection);
      _countryController = TextEditingController(text: chip.country);
      _releaseYearController = TextEditingController(text: chip.releaseYear.toString());
      _discontinuedYearController = TextEditingController(text: chip.discontinuedYear?.toString() ?? '');
      _selectedCategory = chip.category.name;
      _available = chip.available;
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _imagePathController = TextEditingController();
      _collectionController = TextEditingController();
      _countryController = TextEditingController();
      _releaseYearController = TextEditingController();
      _discontinuedYearController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imagePathController.dispose();
    _collectionController.dispose();
    _countryController.dispose();
    _releaseYearController.dispose();
    _discontinuedYearController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
        if (widget.chip != null) {
          await ChipService.updateChip(
          chipId: widget.chip!.id,
          name: _nameController.text.trim(),
          category: _selectedCategory,
          description: _descriptionController.text.trim(),
          imagePath: _imagePathController.text.trim(),
          collection: _collectionController.text.trim(),
          country: _countryController.text.trim(),
          releaseYear: int.parse(_releaseYearController.text.trim()),
          discontinuedYear: _discontinuedYearController.text.trim().isEmpty
              ? null
              : int.parse(_discontinuedYearController.text.trim()),
          available: _available,
          );
        } else {
          print("pupu");
        }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Изменения сохранены')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка: $e')),
        );
      }
    }

    if (mounted) setState(() => _isSaving = false);
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: theme.colorScheme.outlineVariant, // ← цвет из темы
      ),
    );

    // focusedBorder — когда поле активно
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: theme.colorScheme.primary, // ← акцентный цвет при фокусе
        width: 2,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chip != null ? 'Редактировать чипсы' : 'Новые чипсы'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Название
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Название',
                  border: inputBorder,
                  focusedBorder: focusedBorder,
                  enabledBorder: inputBorder,
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Обязательно' : null,
              ),
              const SizedBox(height: 12),

              // Категория — выпадающий список
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Категория',
                  border: inputBorder,
                  focusedBorder: focusedBorder,
                  enabledBorder: inputBorder,
                ),
                items: const [
                  DropdownMenuItem(value: 'classic', child: Text('Классические')),
                  DropdownMenuItem(value: 'maxx', child: Text('Maxx')),
                  DropdownMenuItem(value: 'stix', child: Text('Stix')),
                  DropdownMenuItem(value: 'stax', child: Text('Stax')),
                  DropdownMenuItem(value: 'baked', child: Text('Из печи')),
                  DropdownMenuItem(value: 'ridged', child: Text('Рифленые')),
                ],
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
              const SizedBox(height: 12),

              // Описание
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Описание',
                  border: inputBorder,
                  focusedBorder: focusedBorder,
                  enabledBorder: inputBorder,
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Обязательно' : null,
              ),
              const SizedBox(height: 12),

              // Путь к картинке
              TextFormField(
                controller: _imagePathController,
                decoration: InputDecoration(
                  labelText: 'Путь к картинке',
                  border: inputBorder,
                  focusedBorder: focusedBorder,
                  enabledBorder: inputBorder,
                  hintText: 'например, image.png',
                ),
              ),
              const SizedBox(height: 12),

              // Коллекция
              TextFormField(
                controller: _collectionController,
                decoration: InputDecoration(
                  labelText: 'Коллекция',
                  border: inputBorder,
                  focusedBorder: focusedBorder,
                  enabledBorder: inputBorder,
                ),
              ),
              const SizedBox(height: 12),

              // Страна
              TextFormField(
                controller: _countryController,
                decoration: InputDecoration(
                  labelText: 'Страна',
                  border: inputBorder,
                  focusedBorder: focusedBorder,
                  enabledBorder: inputBorder,
                ),
              ),
              const SizedBox(height: 12),

              // Год выпуска
              TextFormField(
                controller: _releaseYearController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Год выпуска',
                  border: inputBorder,
                  focusedBorder: focusedBorder,
                  enabledBorder: inputBorder,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Обязательно';
                  if (int.tryParse(v) == null) return 'Введите число';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Год снятия с продажи
              TextFormField(
                controller: _discontinuedYearController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Год снятия с продажи (необязательно)',
                  border: inputBorder,
                  focusedBorder: focusedBorder,
                  enabledBorder: inputBorder,
                ),
              ),
              const SizedBox(height: 12),

              // Наличие в продаже
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: SwitchListTile(
                  title: const Text('В продаже'),
                  value: _available,
                  onChanged: (v) => setState(() => _available = v),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Кнопки
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
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
            ],
          ),
        ),
      ),
    );
  }
}
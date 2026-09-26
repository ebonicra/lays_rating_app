import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';


import 'package:lays_rating/models/chip.dart';
import 'package:lays_rating/models/chip_form_data.dart';
import 'package:lays_rating/models/chip_type.dart';
import 'package:lays_rating/services/auth_service.dart';

/// Общая форма создания / редактирования чипса.
class ChipForm extends StatefulWidget {
  const ChipForm({
    super.key,
    required this.formKey,
    required this.initialChip,
    required this.isSaving,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final LaysChip? initialChip;
  final bool isSaving;
  final ValueChanged<ChipFormData> onSubmit;

  @override
  State<ChipForm> createState() => ChipFormState();
}

class ChipFormState extends State<ChipForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _collectionController;
  late final TextEditingController _countryController;
  late final TextEditingController _releaseYearController;

  late ChipType _category;
  late bool _available;
  String? _localImagePath;

  /// Есть ли несохранённые изменения.
  bool get isDirty {
    final chip = widget.initialChip;
    if (_nameController.text.trim() != (chip?.name ?? "Lay's ").trim()) {
      return true;
    }
    if (_descriptionController.text.trim() !=
        (chip?.description ?? '').trim()) {
      return true;
    }
    if (_collectionController.text.trim() !=
        (chip?.collection ?? '').trim()) {
      return true;
    }
    if (_countryController.text.trim() != (chip?.country ?? '').trim()) {
      return true;
    }
    if (_releaseYearController.text.trim() !=
        (chip?.releaseYear.toString() ?? '').trim()) {
      return true;
    }
    if (_category != (chip?.category ?? ChipType.classic)) return true;
    if (_available != (chip?.available ?? true)) return true;
    if (_localImagePath != null) return true;

    return false;
  }

  @override
  void initState() {
    super.initState();

    final chip = widget.initialChip;

    _nameController = TextEditingController(text: chip?.name ?? "Lay's ");
    _descriptionController = TextEditingController(text: chip?.description ?? '');
    _collectionController = TextEditingController(text: chip?.collection ?? '');
    _countryController = TextEditingController(text: chip?.country ?? '');
    _releaseYearController = TextEditingController(
      text: chip?.releaseYear.toString() ?? '',
    );
    _category = chip?.category ?? ChipType.classic;
    _available = chip?.available ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _collectionController.dispose();
    _countryController.dispose();
    _releaseYearController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (image == null || !mounted) return;
    setState(() => _localImagePath = image.path);
  }

  void _submit() {
    if (!widget.formKey.currentState!.validate()) return;

    final data = ChipFormData(
      name: _nameController.text.trim(),
      category: _category,
      description: _descriptionController.text.trim(),
      collection: _collectionController.text.trim(),
      country: _countryController.text.trim(),
      releaseYear: int.parse(_releaseYearController.text.trim()),
      available: _available,
      localImagePath: _localImagePath,
    );

    widget.onSubmit(data);
  }

  Future<void> _onCancel() async {
    if (!isDirty) {
      if (mounted) Navigator.pop(context);
      return;
    }

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

    if (confirmed == true && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
    );

    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImagePicker(theme),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Название',
                hintText: "Например: Lay's Maxx с сыром",
                border: inputBorder,
                focusedBorder: focusedBorder,
                enabledBorder: inputBorder,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Обязательно' : null,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ChipType>(
              value: _category,
              decoration: InputDecoration(
                labelText: 'Категория',
                border: inputBorder,
                focusedBorder: focusedBorder,
                enabledBorder: inputBorder,
              ),
              items: ChipType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.title),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _category = v);
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Описание',
                border: inputBorder,
                focusedBorder: focusedBorder,
                enabledBorder: inputBorder,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Обязательно' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _collectionController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Коллекция',
                border: inputBorder,
                focusedBorder: focusedBorder,
                enabledBorder: inputBorder,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _countryController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Страна',
                border: inputBorder,
                focusedBorder: focusedBorder,
                enabledBorder: inputBorder,
              ),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.isSaving ? null : _onCancel,
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
                    onPressed: widget.isSaving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: widget.isSaving
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
    );
  }

  Widget _buildImagePicker(ThemeData theme) {
    final chip = widget.initialChip;

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImagePreview(theme, chip),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _localImagePath != null
                    ? 'Картинка выбрана ✅'
                    : 'Выбрать картинку',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            ),
            Icon(
              Icons.upload_rounded,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(ThemeData theme, LaysChip? chip) {
    const size = 60.0;

    if (_localImagePath != null) {
      return Image.file(
        File(_localImagePath!),
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    if (chip != null) {
      return CachedNetworkImage(
        imageUrl: '${AuthService.baseUrl}/chips/images/${chip.imagePath}',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => Container(
          width: size,
          height: size,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(child: Icon(Icons.broken_image)),
        ),      );
    }
    return _emptyPreview(theme, size);
  }

  Widget _emptyPreview(ThemeData theme, double size) {
    return Container(
      width: size,
      height: size,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_outlined,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
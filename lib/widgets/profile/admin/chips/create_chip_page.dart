import 'package:flutter/material.dart';

import 'package:lays_rating/models/chip_form_data.dart';
import 'package:lays_rating/services/chip_service.dart';
import 'package:lays_rating/widgets/profile/admin/chips/chip_form.dart';

/// Страница создания нового чипса.
class CreateChipPage extends StatefulWidget {
  const CreateChipPage({super.key});

  @override
  State<CreateChipPage> createState() => _CreateChipPageState();
}

class _CreateChipPageState extends State<CreateChipPage> {
  final _formKey = GlobalKey<FormState>();
  final _chipFormKey = GlobalKey<ChipFormState>();
  bool _isSaving = false;

  Future<void> _save(ChipFormData data) async {
    setState(() => _isSaving = true);

    try {
      final newChipId = await ChipService.createChip(
        name: data.name,
        category: data.category.value,
        description: data.description,
        collection: data.collection,
        country: data.country,
        releaseYear: data.releaseYear,
        available: data.available,
      );

      if (data.localImagePath != null) {
        await ChipService.uploadChipImage(
          chipId: newChipId,
          filePath: data.localImagePath!,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Чипс создан')
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('CreateChipPage._save error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось создать чипс')
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool> _confirmExit() async {
    if (_chipFormKey.currentState?.isDirty != true) return true;

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
        appBar: AppBar(title: const Text('Новый чипс')),
        body: ChipForm(
          key: _chipFormKey,
          formKey: _formKey,
          initialChip: null,
          isSaving: _isSaving,
          onSubmit: _save,
        ),
      ),
    );
  }
}
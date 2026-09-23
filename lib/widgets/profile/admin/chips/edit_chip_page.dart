import 'package:flutter/material.dart';

import 'package:lays_rating/models/chip.dart';
import 'package:lays_rating/models/chip_form_data.dart';
import 'package:lays_rating/services/chip_service.dart';
import 'package:lays_rating/widgets/profile/admin/chips/chip_form.dart';

/// Страница редактирования чипса.
class EditChipPage extends StatefulWidget {
  const EditChipPage({
    super.key,
    required this.chip,
  });

  final LaysChip chip;

  @override
  State<EditChipPage> createState() => _EditChipPageState();
}

class _EditChipPageState extends State<EditChipPage> {
  final _formKey = GlobalKey<FormState>();
  final _chipFormKey = GlobalKey<ChipFormState>();
  bool _isSaving = false;

  Future<void> _save(ChipFormData data) async {
    setState(() => _isSaving = true);

    try {
      if (data.localImagePath != null) {
        await ChipService.uploadChipImage(
          chipId: widget.chip.id,
          filePath: data.localImagePath!,
        );
      }

      await ChipService.updateChip(
        chipId: widget.chip.id,
        name: data.name,
        category: data.category.value,
        description: data.description,
        collection: data.collection,
        country: data.country,
        releaseYear: data.releaseYear,
        available: data.available,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Сохранено')
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('EditChipPage._save error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось сохранить')
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
                    backgroundColor:
                        Theme.of(context).colorScheme.error,
                    foregroundColor:
                        Theme.of(context).colorScheme.onError,
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
        appBar: AppBar(title: const Text('Редактировать чипс')),
        body: ChipForm(
          key: _chipFormKey,
          formKey: _formKey,
          initialChip: widget.chip,
          isSaving: _isSaving,
          onSubmit: _save,
        ),
      ),
    );
  }
}
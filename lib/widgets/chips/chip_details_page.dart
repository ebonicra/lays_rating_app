import 'package:flutter/material.dart';

import 'package:lays_rating/models/chip.dart';
import 'package:lays_rating/models/chip_preference.dart';
import 'package:lays_rating/services/chip_service.dart';
import 'package:lays_rating/services/preference_service.dart';
import 'package:lays_rating/services/user_service.dart';
import 'package:lays_rating/widgets/chips/chip_details_view.dart';
import 'package:lays_rating/widgets/chips/chip_admin_menu_button.dart';
import 'package:lays_rating/widgets/profile/admin/chips/edit_chip_page.dart';


class ChipDetailsPage extends StatefulWidget {
  const ChipDetailsPage({
    super.key,
    required this.chipId,
  });

  final int chipId;

  @override
  State<ChipDetailsPage> createState() => _ChipDetailsPageState();
}

class _ChipDetailsPageState extends State<ChipDetailsPage> {
  LaysChip? chip;
  ChipPreference? preference;
  bool isLoading = true;

  bool get _isAdmin => UserService.currentUser?.isAdmin ?? false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final chipResult = await ChipService.fetchChipById(widget.chipId);
      final preferenceResult =
          await PreferenceService.getPreference(widget.chipId);

      if (!mounted) return;
      setState(() {
        chip = chipResult;
        preference = preferenceResult;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('ChipDetailsPage.loadData error: $e');
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> changeRating(int value) async {
    try {
      final ChipPreference updated;
      if (value == 0) {
        updated = await PreferenceService.deleteRating(widget.chipId);
      } else {
        updated = await PreferenceService.updatePreference(
          chipId: widget.chipId,
          rating: value,
        );
      }

      final updatedChip =
          await ChipService.fetchChipById(widget.chipId);

      if (!mounted) return;
      setState(() {
        preference = updated;
        chip = updatedChip;
      });
    } catch (e) {
      debugPrint('ChipDetailsPage.changeRating error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось сохранить оценку')
        ),
      );
    }
  }

  Future<void> toggleFavorite() async {
    if (preference == null) return;

    try {
      final updated = await PreferenceService.updatePreference(
        chipId: widget.chipId,
        isFavorite: !preference!.isFavorite,
      );

      if (!mounted) return;
      setState(() => preference = updated);
    } catch (e) {
      debugPrint('ChipDetailsPage.toggleFavorite error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось сохранить')
        ),
      );
    }
  }

  Future<void> toggleTried() async {
    if (preference == null) return;

    try {
      final updated = await PreferenceService.updatePreference(
        chipId: widget.chipId,
        isTried: !preference!.isTried,
      );

      if (!mounted) return;
      setState(() => preference = updated);
    } catch (e) {
      debugPrint('ChipDetailsPage.toggleTried error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось сохранить')
        ),
      );
    }
  }

  // void _openAddChip() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => const EditChipPage(chip: null),
  //     ),
  //   );
  // }

  void _openEditChip() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditChipPage(chip: chip!),
      ),
    ).then((wasEdited) {
      if (wasEdited == true) loadData();
    });
  }

  void _deleteChip() {
    // TODO: удалить чипс
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chip?.name ?? 'Загрузка...'),
        actions: [
          if (_isAdmin)
            ChipAdminMenuButton(
              // onAdd: _openAddChip,
              onEdit: _openEditChip,
              onDelete: _deleteChip,
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : chip == null || preference == null
              ? const Center(child: Text('Не удалось загрузить данные'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ChipDetailsView(
                    chip: chip!,
                    preference: preference!,
                    onRatingChanged: changeRating,
                    onFavoriteChanged: toggleFavorite,
                    onTriedChanged: toggleTried,
                  ),
                ),
    );
  }
}
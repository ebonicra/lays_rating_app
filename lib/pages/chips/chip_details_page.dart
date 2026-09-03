import 'package:flutter/material.dart';

import 'package:lays_rating/models/chip.dart';
import 'package:lays_rating/models/chip_preference.dart';

import 'package:lays_rating/services/chip_service.dart';
import 'package:lays_rating/services/chip_preference_service.dart';
import 'package:lays_rating/services/user_service.dart'; // если ещё нет
import 'package:lays_rating/pages/admin/edit_chip_page.dart';


import 'package:lays_rating/widgets/chip_details_view.dart';


class ChipDetailsPage extends StatefulWidget {
  final int chipId;

  const ChipDetailsPage({
    super.key,
    required this.chipId,
  });

  @override
  State<ChipDetailsPage> createState() => _ChipDetailsPageState();
}


class _ChipDetailsPageState extends State<ChipDetailsPage> {
  LaysChip? chip;
  ChipPreference? preference;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final chipResult =
          await ChipService.fetchChipById(
            widget.chipId,
          );
      final preferenceResult =
          await ChipPreferenceService.getPreference(
            widget.chipId,
          );

      setState(() {
        chip = chipResult;
        preference = preferenceResult;
        isLoading = false;
      });
    } catch(e) {
      debugPrint("Loading error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> changeRating(int value) async {
    final updated =
        await ChipPreferenceService.updatePreference(
          chipId: widget.chipId,
          rating: value,
        );

    final updatedChip =
      await ChipService.fetchChipById(
        widget.chipId
      );


    setState(() {
      preference = updated;
      chip = updatedChip;
    });
  }

  Future<void> toggleFavorite() async {
    if(preference == null) {
      return;
    }

    final updated =
        await ChipPreferenceService.updatePreference(
          chipId: widget.chipId,
          isFavorite: !preference!.isFavorite,
        );

    setState(() {
      preference = updated;
    });
  }

  Future<void> toggleTried() async {
    if(preference == null) {
      return;
    }

    final updated =
        await ChipPreferenceService.updatePreference(
          chipId: widget.chipId,
          isTried: !preference!.isTried,
        );

    setState(() {
      preference = updated;
    });
  }

  bool get _isAdmin {
    return UserService.currentUser?.isAdmin ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          chip?.name ?? "Загрузка...",
        ),


        actions: [
          // Три точки — только для админов
          if (_isAdmin)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // ← скругление
              ),
              constraints: const BoxConstraints(maxWidth: 170),
              onSelected: (value) {
                switch (value) {
                  case 'add':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditChipPage(chip: null), // ← создание нового
                      ),
                    ).then((wasCreated) {
                      if (wasCreated == true) {
                        // Можно вернуться назад или обновить список
                      }
                    });
                    break;
                  case 'edit':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditChipPage(chip: chip!),
                      ),
                    ).then((wasEdited) {
                      if (wasEdited == true) {
                        loadData(); // перезагружаем данные
                      }
                    });
                    break;
                  case 'delete':
                    // TODO: удалить
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'add',
                  height: 25,
                  child: ListTile(
                    leading: Icon(Icons.add_circle_outline, size: 20, color: Colors.red),
                    title: Text('Добавить', style: TextStyle(color: Colors.red, fontSize: 14)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  height: 25,
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined, size: 20, color: Colors.red),
                    title: Text('Редактировать', style: TextStyle(color: Colors.red, fontSize: 14)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  height: 25,
                  child: ListTile(
                    leading: Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    title: Text('Удалить', style: TextStyle(color: Colors.red, fontSize: 14)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
        ],

      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : chip == null || preference == null
              ? const Center(
                  child: Text(
                    "Не удалось загрузить данные",
                  ),
                )
              : Padding(
                  padding:
                  const EdgeInsets.all(16),
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
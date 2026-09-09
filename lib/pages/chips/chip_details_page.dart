import 'package:flutter/material.dart';

import 'package:lays_rating/models/chip.dart';
import 'package:lays_rating/models/chip_preference.dart';

import 'package:lays_rating/services/chip_service.dart';
import 'package:lays_rating/services/chip_preference_service.dart';
import 'package:lays_rating/services/comments_server.dart';
import 'package:lays_rating/services/user_service.dart'; // если ещё нет
import 'package:lays_rating/pages/admin/edit_chip_page.dart';
import 'package:lays_rating/widgets/comments_page.dart';


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
    final theme = Theme.of(context);
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
      // bottomNavigationBar: _buildCommentBar(theme),
    );
  }

  
  Widget _buildCommentBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          // Поле для комментария
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Открываем диалог создания комментария
                _showCommentDialog();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_note_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Написать комментарий...',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Кнопка все комментарии
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CommentsPage(chipId: chip!.id),
                ),
              ).then((_) => loadData());
            },
            icon: Icon(
              Icons.forum_rounded,
              color: theme.colorScheme.primary,
            ),
            tooltip: 'Все комментарии',
          ),
        ],
      ),
    );
  }

  void _showCommentDialog() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Новое важное мнение🧐',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 4,
                minLines: 2,
                decoration: InputDecoration(
                  hintText: 'Ну давай, расскажи, какая это хуета...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  if (controller.text.trim().isNotEmpty) {
                    try {
                      await CommentsService.createComment(
                        chipId: chip!.id,
                        text: controller.text.trim(),
                      );
                      if (mounted) {
                        Navigator.pop(context);
                        loadData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ Комментарий добавлен')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Не удалось добавить')),
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Отправить'),
              ),
            ],
          ),
        );
      },
    );
  }
}
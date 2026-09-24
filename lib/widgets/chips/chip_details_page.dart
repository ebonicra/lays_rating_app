import 'package:flutter/material.dart';

import 'package:lays_rating/models/chip.dart';
import 'package:lays_rating/models/chip_preference.dart';

import 'package:lays_rating/services/chip_service.dart';
import 'package:lays_rating/services/preference_service.dart';
import 'package:lays_rating/services/user_service.dart';

import 'package:lays_rating/widgets/chips/chip_details_view.dart';
import 'package:lays_rating/widgets/chips/chip_details_result.dart';
import 'package:lays_rating/widgets/chips/chip_admin_menu_button.dart';
import 'package:lays_rating/widgets/profile/admin/chips/edit_chip_page.dart';
import 'package:lays_rating/widgets/profile/admin/chips/delete_chip_dialog.dart';
import 'package:lays_rating/widgets/chips/comments/comments_section.dart';
import 'package:lays_rating/widgets/chips/chip_ratings_sheet.dart';

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
  final _commentsKey = GlobalKey<CommentsSectionState>();
  LaysChip? chip;
  ChipPreference? preference;
  bool isLoading = true;

  /// Чипс, который нужно вернуть на предыдущий экран.
  /// null — если ничего значимого не менялось.
  LaysChip? _resultChip;

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

      await _commentsKey.currentState?.refresh();
    } catch (e) {
      debugPrint('ChipDetailsPage.loadData error: $e');
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  /// Запоминаем чипс, который нужно вернуть на предыдущий экран.
  void _markResult(LaysChip? updated) {
    if (updated == null) return;
    _resultChip = updated;
  }

  void _onCommentsCountChanged(int newCount) {
    final current = chip;
    if (current == null) return;
    if (current.commentCount == newCount) return;

    final updated = current.copyWith(commentCount: newCount);
    setState(() => chip = updated);
    _markResult(updated);
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

      final updatedChip = await ChipService.fetchChipById(widget.chipId);

      if (!mounted) return;
      setState(() {
        preference = updated;
        chip = updatedChip;
      });
      _markResult(updatedChip);
    } catch (e) {
      debugPrint('ChipDetailsPage.changeRating error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось сохранить оценку'),
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

      // favorite/tried отображаются на карточке, поэтому нужно вернуть чипс.
      // Локально обновляем флаг, чтобы не ходить на сервер ещё раз.
      final current = chip;
      if (current != null) {
        final updatedChip = current.copyWith(isFavorite: updated.isFavorite);
        setState(() => chip = updatedChip);
        _markResult(updatedChip);
      }
    } catch (e) {
      debugPrint('ChipDetailsPage.toggleFavorite error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось сохранить'),
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

      final current = chip;
      if (current != null) {
        final updatedChip = current.copyWith(isTried: updated.isTried);
        setState(() => chip = updatedChip);
        _markResult(updatedChip);
      }
    } catch (e) {
      debugPrint('ChipDetailsPage.toggleTried error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось сохранить'),
        ),
      );
    }
  }

  void _openRatingsSheet() {
    final chip = this.chip;
    if (chip == null) return;
    ChipRatingsSheet.show(context, chip.id);
  }

  void _openEditChip() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditChipPage(chip: chip!),
      ),
    ).then((wasEdited) {
      if (wasEdited == true) loadData().then((_) {
        _markResult(chip);
      });
    });
  }

  Future<void> _deleteChip() async {
    final chip = this.chip;
    if (chip == null) return;

    final confirmed = await DeleteChipDialog.show(context);
    if (confirmed != true || !mounted) return;
    try {
      await ChipService.deleteChip(chip.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Чипс удалён'),
        ),
      );
      Navigator.pop(context, ChipDeleted(chip.id));
    } catch (e) {
      debugPrint('ChipDetailsPage._deleteChip error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось удалить чипс'),
        ),
      );
    }
  }

  bool _isPopping = false;

  Future<void> _popWithResult() async {
    if (_isPopping) return;
    _isPopping = true;

    LaysChip? fresh;
    try {
      fresh = await ChipService.fetchChipById(widget.chipId);
    } catch (e) {
      debugPrint('ChipDetailsPage._popWithResult error: $e');
    }

    if (!mounted) return;

    if (fresh != null) {
      Navigator.pop(context, ChipUpdated(fresh));
    } else {
      final result = _resultChip;
      if (result != null) {
        Navigator.pop(context, ChipUpdated(result));
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<ChipDetailsResult>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _popWithResult();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(chip?.name ?? 'Загрузка...'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _popWithResult,
          ),
          actions: [
            if (_isAdmin)
              ChipAdminMenuButton(
                onEdit: _openEditChip,
                onDelete: _deleteChip,
              ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: loadData,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chip == null || preference == null) {
      return const Center(child: Text('Не удалось загрузить данные'));
    }

    return ChipDetailsView(
      chip: chip!,
      preference: preference!,
      onRatingChanged: changeRating,
      onFavoriteChanged: toggleFavorite,
      onTriedChanged: toggleTried,
      onCommentsCountChanged: _onCommentsCountChanged,
      onAverageRatingLongPress: _openRatingsSheet,
      commentsKey: _commentsKey,
    );
  }
}
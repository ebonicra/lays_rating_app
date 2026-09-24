// lib/widgets/chips/chip_details_result.dart
import 'package:lays_rating/models/chip.dart';

sealed class ChipDetailsResult {
  const ChipDetailsResult();
}

/// Чипс изменился (рейтинг, favorite, tried, редактирование).
class ChipUpdated extends ChipDetailsResult {
  const ChipUpdated(this.chip);
  final LaysChip chip;
}

/// Чипс удалён.
class ChipDeleted extends ChipDetailsResult {
  const ChipDeleted(this.chipId);
  final int chipId;
}
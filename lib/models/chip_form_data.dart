import 'package:lays_rating/models/chip_type.dart';

/// Данные формы создания / редактирования чипса.
class ChipFormData {
  const ChipFormData({
    required this.name,
    required this.category,
    required this.description,
    required this.collection,
    required this.country,
    required this.releaseYear,
    required this.available,
    this.localImagePath,
  });

  final String name;
  final ChipType category;
  final String description;
  final String collection;
  final String country;
  final int releaseYear;
  final bool available;

  /// Локальный путь к выбранной картинке (если пользователь выбрал новую).
  final String? localImagePath;
}
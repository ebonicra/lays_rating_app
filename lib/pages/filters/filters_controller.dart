import 'package:flutter/foundation.dart';

import 'package:lays_rating/models/chip_type.dart';
import 'package:lays_rating/models/user_filters.dart';
import 'package:lays_rating/services/chip_service.dart';
import 'package:lays_rating/services/filters_service.dart';

/// Состояние и логика страницы фильтров.
class FiltersController extends ChangeNotifier {
  FiltersController();

  final Set<String> _selectedFilters = {};
  bool _russiaOnly = false;
  bool _availableOnly = false;
  bool _isLoading = true;

  Map<String, ChipCategoryStats> _stats = {};

  Set<String> get selectedFilters => Set.unmodifiable(_selectedFilters);
  bool get russiaOnly => _russiaOnly;
  bool get availableOnly => _availableOnly;
  bool get isLoading => _isLoading;
  Map<String, ChipCategoryStats> get stats => Map.unmodifiable(_stats);

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Фильтры и статистика грузятся параллельно
      final results = await Future.wait([
        FiltersService.getFilters(),
        ChipService.getStats(),
      ]);

      final UserFilters filters = results[0] as UserFilters;
      final stats = results[1] as Map<String, ChipCategoryStats>;

      _selectedFilters
        ..clear()
        ..addAll(filters.filters);
      _russiaOnly = filters.russiaOnly;
      _availableOnly = filters.availableOnly;
      _stats = stats;
    } catch (e) {
      debugPrint('FiltersController.load error: $e');
      // Не сбрасываем isLoading в false только в finally —
      // если getStats() упал, фильтры всё равно хотим показать.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Перезагрузить только статистику (например, после возврата на страницу).
  Future<void> refreshStats() async {
    try {
      final stats = await ChipService.getStats();
      _stats = stats;
      notifyListeners();
    } catch (e) {
      debugPrint('FiltersController.refreshStats error: $e');
    }
  }

  Future<void> toggleFilter(ChipType type) async {
    final wasSelected = _selectedFilters.contains(type.value);

    if (wasSelected) {
      _selectedFilters.remove(type.value);
    } else {
      _selectedFilters.add(type.value);
    }
    notifyListeners();

    try {
      await FiltersService.updateFilters(
        filters: _selectedFilters.toList(),
      );
    } catch (_) {
      if (wasSelected) {
        _selectedFilters.add(type.value);
      } else {
        _selectedFilters.remove(type.value);
      }
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleRussiaOnly() async {
    _russiaOnly = !_russiaOnly;
    notifyListeners();

    try {
      await FiltersService.updateFilters(russiaOnly: _russiaOnly);
    } catch (_) {
      _russiaOnly = !_russiaOnly;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleAvailableOnly() async {
    _availableOnly = !_availableOnly;
    notifyListeners();

    try {
      await FiltersService.updateFilters(availableOnly: _availableOnly);
    } catch (_) {
      _availableOnly = !_availableOnly;
      notifyListeners();
      rethrow;
    }
  }
}
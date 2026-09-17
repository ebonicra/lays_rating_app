import 'package:flutter/foundation.dart';

import 'package:lays_rating/models/chip_type.dart';
import 'package:lays_rating/models/user_filters.dart';
import 'package:lays_rating/services/filters_service.dart';

/// Состояние и логика страницы фильтров.
class FiltersController extends ChangeNotifier {
  FiltersController();

  final Set<String> _selectedFilters = {};
  bool _russiaOnly = false;
  bool _availableOnly = false;
  bool _isLoading = true;

  Set<String> get selectedFilters => Set.unmodifiable(_selectedFilters);
  bool get russiaOnly => _russiaOnly;
  bool get availableOnly => _availableOnly;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      final UserFilters filters = await FiltersService.getFilters();
      _selectedFilters
        ..clear()
        ..addAll(filters.filters);
      _russiaOnly = filters.russiaOnly;
      _availableOnly = filters.availableOnly;
    } finally {
      _isLoading = false;
      notifyListeners();
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
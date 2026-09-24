import 'package:flutter/foundation.dart';

import 'package:lays_rating/models/chip.dart';
import 'package:lays_rating/services/chip_service.dart';
import 'package:lays_rating/services/filters_service.dart';

/// Состояние и логика страницы чипсов
class ChipsController extends ChangeNotifier {
  ChipsController();

  List<LaysChip> _allChips = [];
  List<LaysChip> _visibleChips = [];

  bool _isLoading = true;      // первая загрузка — показываем спиннер на весь экран
  bool _isRefreshing = false;  // повторная — только RefreshIndicator

  String _searchQuery = '';
  String _sortField = 'rating';
  bool _sortAscending = false;

  List<LaysChip> get visibleChips => List.unmodifiable(_visibleChips);
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String get searchQuery => _searchQuery;
  String get sortField => _sortField;
  bool get sortAscending => _sortAscending;

  /// Первая загрузка (при открытии страницы).
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    await _fetch();
    _isLoading = false;
    notifyListeners();
  }

  /// Pull-to-refresh: не сбрасывает список, не переключает экран в лоадер.
  Future<void> refresh() async {
    _isRefreshing = true;
    notifyListeners();
    await _fetch();
    _isRefreshing = false;
    notifyListeners();
  }

  Future<void> _fetch() async {
    try {
      final filters = await FiltersService.getFilters();
      final result = await ChipService.fetchChips(
        categories: filters.filters,
      );

      _allChips = result.where((chip) {
        if (filters.russiaOnly &&
            !chip.country.toLowerCase().contains('россия')) {
          return false;
        }
        if (filters.availableOnly && !chip.available) {
          return false;
        }
        return true;
      }).toList();

      _rebuildVisible();
    } catch (e) {
      // Тут можно пробросить ошибку или залогировать
      debugPrint('ChipsController._fetch error: $e');
    }
  }

  void setQuery(String query) {
    _searchQuery = query;
    _rebuildVisible();
    notifyListeners();
  }

  void toggleSort(String field) {
    if (_sortField == field) {
      _sortAscending = !_sortAscending;
    } else {
      _sortField = field;
      _sortAscending = false;
    }
    _rebuildVisible();
    notifyListeners();
  }

  bool replaceChip(LaysChip updated) {
    final index = _allChips.indexWhere((c) => c.id == updated.id);
    if (index == -1) return false;

    _allChips[index] = updated;
    _rebuildVisible();
    notifyListeners();

    return _visibleChips.any((c) => c.id == updated.id);
  }

  void removeChip(int chipId) {
    _allChips.removeWhere((c) => c.id == chipId);
    _rebuildVisible();
    notifyListeners();
  }

  int indexOfVisible(int chipId) {
    return _visibleChips.indexWhere((c) => c.id == chipId);
  }

  void _rebuildVisible() {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = query.isEmpty
        ? List<LaysChip>.from(_allChips)
        : _allChips.where((chip) {
            return chip.name.toLowerCase().contains(query);
          }).toList();

    filtered.sort(_compare);
    _visibleChips = filtered;
  }

  int _compare(LaysChip a, LaysChip b) {
    int result;
    switch (_sortField) {
      case 'name':
        result = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        return _sortAscending ? -result : result;
      case 'date':
        result = a.releaseYear.compareTo(b.releaseYear);
        return _sortAscending ? result : -result;
      case 'rating':
      default:
        result = a.rating.average.compareTo(b.rating.average);
        return _sortAscending ? result : -result;
    }
  }
}
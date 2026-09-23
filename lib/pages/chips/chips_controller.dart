import 'package:flutter/foundation.dart';

import 'package:lays_rating/models/chip.dart';
import 'package:lays_rating/services/chip_service.dart';
import 'package:lays_rating/services/filters_service.dart';

/// Состояние и логика страницы чипсов
class ChipsController extends ChangeNotifier {
  ChipsController();

  List<LaysChip> _allChips = [];
  List<LaysChip> _visibleChips = [];

  bool _isLoading = true;
  String _searchQuery = '';
  String _sortField = 'rating';
  bool _sortAscending = false;

  List<LaysChip> get visibleChips => List.unmodifiable(_visibleChips);
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get sortField => _sortField;
  bool get sortAscending => _sortAscending;


  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

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
    } finally {
      _isLoading = false;
      notifyListeners();
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
        result = a.id.compareTo(b.id);
        return _sortAscending ? result : -result;
      case 'rating':
      default:
        result = a.rating.average.compareTo(b.rating.average);
        return _sortAscending ? result : -result;
    }
  }
}
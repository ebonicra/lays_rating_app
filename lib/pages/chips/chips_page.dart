import 'package:flutter/material.dart';
import '../../services/chip_service.dart';
import '../../services/preference_service.dart';
import '../../widgets/chip_card.dart';
import '../../models/chip.dart';


class ChipsPage extends StatefulWidget {
  const ChipsPage({super.key});

  @override
  State<ChipsPage> createState() => _ChipsPageState();
}


class _ChipsPageState extends State<ChipsPage> {
  List<LaysChip> chips = [];         // все чипсы
  List<LaysChip> filteredChips = []; // отфильтрованные
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _sortField = 'rating'; // rating, name, date
  bool _sortAscending = false; 

  @override
  void initState() {
    super.initState();
    loadChips();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadChips() async {
    setState(() => isLoading = true);

    try {
      final filters = await PreferenceService.getPreferences();
      final result = await ChipService.fetchChips(
        categories: filters.categories,
      );

      final filtered = result.where((chip) {
        if (filters.russiaOnly && !chip.country.toLowerCase().contains('россия')) {
          return false;
        }
        if (filters.availableOnly && !chip.available) {
          return false;
        }
        return true;
      }).toList();

      if (mounted) {
        setState(() {
          chips = filtered;
          filteredChips = filtered;
          isLoading = false;
        });
        
        _applySorting(); // ← сортируем после загрузки
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _applySorting() {
    switch (_sortField) {
      case 'rating':
        filteredChips.sort((a, b) {
          final result = a.rating.average.compareTo(b.rating.average);
          return _sortAscending ? result : -result;
        });
        break;
      case 'name':
        filteredChips.sort((a, b) {
          final result = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          return _sortAscending ? -result : result;
        });
        break;
      case 'date':
        filteredChips.sort((a, b) {
          final result = a.id.compareTo(b.id);
          return _sortAscending ? result : -result;
        });
        break;
    }
    setState(() {});
  }

  void _toggleSort(String field) {
    if (_sortField == field) {
      // Та же опция — инвертируем направление
      setState(() => _sortAscending = !_sortAscending);
    } else {
      // Новая опция — по умолчанию по убыванию
      setState(() {
        _sortField = field;
        _sortAscending = false;
      });
    }
    _applySorting();
  }

  void _filterChips(String query) {
    if (query.trim().isEmpty) {
      setState(() => filteredChips = chips);
      return;
    }

    final lowerQuery = query.toLowerCase().trim();
    
    setState(() {
      filteredChips = chips.where((chip) {
        return chip.name.toLowerCase().contains(lowerQuery) ||
            chip.description.toLowerCase().contains(lowerQuery);
      }).toList();
    });

    _applySorting(); 
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _filterChips,
                decoration: const InputDecoration(
                  hintText: 'Поиск...',
                  border: InputBorder.none,
                ),
              )
            : const Text("Рейтинг Lay's"),
        actions: [
          Transform.translate(
            offset: const Offset(14, 0), // ← сдвигаем влево
            child: IconButton(
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    _searchController.clear();
                    _filterChips('');
                  }
                  _isSearching = !_isSearching;
                });
              },
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              tooltip: _isSearching ? 'Закрыть' : 'Поиск',
            )
          ),
          Transform.translate(
            offset: const Offset(4, 0),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.swap_vert_rounded),
              iconSize: 26,
              tooltip: 'Сортировка',
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: _toggleSort, // ← передаём поле
              itemBuilder: (context) => [
                _buildSortItem('rating', 'По рейтингу', Icons.star_rounded),
                _buildSortItem('name', 'По названию', Icons.sort_by_alpha_rounded),
                _buildSortItem('date', 'По дате', Icons.calendar_today_rounded),
              ],
            ),
          ),
        ],
      ),
      body: filteredChips.isEmpty
          ? Center(
              child: Text(
                _searchController.text.isEmpty
                    ? 'Нет чипсов с такими фильтрами'
                    : 'Ничего не найдено',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            )
          : ListView.builder(
              itemCount: filteredChips.length,      // ← было chips
              itemBuilder: (context, index) {
                return ChipCard(
                  chip: filteredChips[index],       // ← было chips
                  onReturn: loadChips,
                );
              },
            ),
    );
  }

  PopupMenuItem<String> _buildSortItem(String value, String label, IconData icon) {
    final isActive = _sortField == value;
    
    return PopupMenuItem<String>(
      value: value,
      height: 40,
      // padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        width: 140,
        child: Row(
          children: [
            // Icon(
            //   icon,
            //   size: 18,
            //   color: isActive ? Colors.amber : Colors.grey,
            // ),
            // const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            // Стрелка вверх/вниз для активной опции
            if (isActive)
              Icon(
                _sortAscending 
                  ? Icons.arrow_downward_rounded  // возрастание → стрелка вниз
                  : Icons.arrow_upward_rounded,   // убывание → стрелка вверх
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}



import 'package:flutter/material.dart';

import 'package:lays_rating/widgets/chips/chip_compact_card.dart';
import 'package:lays_rating/widgets/chips/chips_sort_menu.dart';

import 'chips_controller.dart';


class ChipsPage extends StatefulWidget {
  const ChipsPage({super.key});

  @override
  State<ChipsPage> createState() => _ChipsPageState();
}

class _ChipsPageState extends State<ChipsPage> {
  late final ChipsController _controller;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller = ChipsController();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      if (_isSearching) {
        _searchController.clear();
        _controller.setQuery('');
      }
      _isSearching = !_isSearching;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: _controller.setQuery,
                    decoration: const InputDecoration(
                      hintText: 'Поиск...',
                      border: InputBorder.none,
                    ),
                  )
                : const Text("Рейтинг Lay's"),
            actions: [
              Transform.translate(
                offset: const Offset(14, 0),
                child: IconButton(
                  onPressed: _toggleSearch,
                  icon: Icon(_isSearching ? Icons.close : Icons.search),
                  tooltip: _isSearching ? 'Закрыть' : 'Поиск',
                ),
              ),
              Transform.translate(
                offset: const Offset(4, 0),
                child: ChipsSortMenu(
                  sortField: _controller.sortField,
                  sortAscending: _controller.sortAscending,
                  onSelected: _controller.toggleSort,
                ),
              ),
            ],
          ),
          body: _buildBody(context),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    final chips = _controller.visibleChips;

    if (chips.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      final text = _controller.searchQuery.isEmpty
          ? 'Нет чипсов с такими фильтрами'
          : 'Ничего не найдено';

      return Center(
        child: Text(
          text,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: chips.length,
      itemBuilder: (context, index) {
        return ChipCompactCard(
          chip: chips[index],
          onReturn: _controller.load,
        );
      },
    );
  }
}
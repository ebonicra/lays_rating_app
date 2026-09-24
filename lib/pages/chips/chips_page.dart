import 'package:flutter/material.dart';

import 'package:lays_rating/models/chip.dart';
import 'package:lays_rating/pages/chips/chips_controller.dart';
import 'package:lays_rating/widgets/chips/chip_compact_card.dart';
import 'package:lays_rating/widgets/chips/chip_details_page.dart';
import 'package:lays_rating/widgets/chips/chip_details_result.dart';
import 'package:lays_rating/widgets/chips/chips_sort_menu.dart';

/// Страница со списком чипсов: поиск, сортировка и переход к деталям.

class ChipsPage extends StatefulWidget {
  const ChipsPage({super.key});

  @override
  State<ChipsPage> createState() => _ChipsPageState();
}

class _ChipsPageState extends State<ChipsPage> {
  late final ChipsController _controller;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
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
    _scrollController.dispose();
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

  Future<void> _openChip(LaysChip chip) async {
    final result = await Navigator.push<ChipDetailsResult>(
      context,
      MaterialPageRoute(
        builder: (_) => ChipDetailsPage(chipId: chip.id),
      ),
    );

    if (!mounted || result == null) return;

    switch (result) {
      case ChipUpdated(:final chip):
        _controller.replaceChip(chip);
      case ChipDeleted(:final chipId):
        _controller.removeChip(chipId);
    }
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
          body: RefreshIndicator(
            onRefresh: _controller.refresh,
            child: _buildBody(context),
          ),
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
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 4),
      itemCount: chips.length,
      itemBuilder: (context, index) {
        final chip = chips[index];
        return ChipCompactCard(
          chip: chip,
          onTap: () => _openChip(chip),
        );
      },
    );
  }
}
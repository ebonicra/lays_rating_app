import 'package:flutter/material.dart';

import 'package:lays_rating/models/chip_type.dart';
import 'package:lays_rating/widgets/filters/compact_filter_card.dart';
import 'package:lays_rating/widgets/filters/filter_grid.dart';

import 'filters_controller.dart';


class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late final FiltersController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FiltersController();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleFilter(ChipType type) async {
    try {
      await _controller.toggleFilter(type);
    } catch (_) {
      _showErrorSnack();
    }
  }

  Future<void> _toggleRussiaOnly() async {
    try {
      await _controller.toggleRussiaOnly();
    } catch (_) {
      _showErrorSnack();
    }
  }

  Future<void> _toggleAvailableOnly() async {
    try {
      await _controller.toggleAvailableOnly();
    } catch (_) {
      _showErrorSnack();
    }
  }

  void _showErrorSnack() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Не удалось сохранить настройки')),
    );
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
          appBar: AppBar(title: const Text('Фильтры')),
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  child: FilterGrid(
                    types: ChipType.values,
                    selected: _controller.selectedFilters,
                    onToggle: _toggleFilter,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: CompactFilterCard(
                        icon: Icons.public_rounded,
                        label: 'Только Россия',
                        isSelected: _controller.russiaOnly,
                        onTap: _toggleRussiaOnly,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CompactFilterCard(
                        icon: Icons.shopping_cart_rounded,
                        label: 'В продаже',
                        isSelected: _controller.availableOnly,
                        onTap: _toggleAvailableOnly,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
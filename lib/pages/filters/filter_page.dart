import 'package:flutter/material.dart';

import 'package:lays_rating/models/chip_type.dart';
import 'package:lays_rating/widgets/filters/compact_filter_grid.dart';
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

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось сохранить настройки')
        ),
      );
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
          appBar: AppBar(title: const Text('Фильтры')),
          body: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                Expanded(
                  child: FilterGrid(
                    types: ChipType.values,
                    selected: _controller.selectedFilters,
                    onToggle: (type) => _run(
                      () => _controller.toggleFilter(type),
                    ),
                    statsFor: (type) {
                      final s = _controller.stats[type.value];
                      if (s == null) return null;
                      return (total: s.total, tried: s.tried);
                    },
                  ),
                ),
                const SizedBox(height: 2),
                CompactFilterGrid(
                  russiaOnly: _controller.russiaOnly,
                  availableOnly: _controller.availableOnly,
                  onRussiaOnlyTap: () => _run(_controller.toggleRussiaOnly),
                  onAvailableOnlyTap: () => _run(
                    _controller.toggleAvailableOnly,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        );
      },
    );
  }
}
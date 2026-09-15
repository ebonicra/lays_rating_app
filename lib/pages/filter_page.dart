import 'package:flutter/material.dart';

import '../../models/chip_category.dart';
import '../../widgets/filter_card.dart';
import '../services/filter_service.dart';


class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}



class _FilterPageState extends State<FilterPage> {
  final Set<String> selectedCategories = {};
  bool _russiaOnly = false;      // ← добавили
  bool _availableOnly = false; 
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    try {
      final filters = await FilterService.getFilters();
      setState(() {
        selectedCategories
          ..clear()
          ..addAll(filters.categories);
        _russiaOnly = filters.russiaOnly;
        _availableOnly = filters.availableOnly;
        isLoading = false;
      });
    } catch(e){
      setState(() {
        isLoading = false;
      });

      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Ошибка загрузки фильтров: $e",
          ),
        ),
      );
    }
  }


  Future<void> toggleCategory(ChipCategory category) async {
    final wasSelected =
        selectedCategories.contains(
          category.value,
        );

    setState(() {
      if(wasSelected){
        selectedCategories.remove(
          category.value,
        );
      } else {
        selectedCategories.add(
          category.value,
        );
      }
    });

    try {
      await FilterService.updateFilters(
        categories: selectedCategories.toList(),
        russiaOnly: _russiaOnly,
        availableOnly: _availableOnly,
      );
    } catch(e){
      setState(() {
        if(wasSelected){
          selectedCategories.add(
            category.value,
          );
        } else {
          selectedCategories.remove(
            category.value,
          );
        }
      });

      if(!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Не удалось сохранить настройки",
          ),
        ),
      );
    }
  }


@override
Widget build(BuildContext context) {
  if (isLoading) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: const Text('Фильтры'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // Сетка категорий
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardHeight = (constraints.maxHeight - 35) / 3;
                final cardWidth = (constraints.maxWidth - 12) / 2;
                final aspectRatio = cardWidth / cardHeight;

                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: aspectRatio,
                  ),
                  itemCount: ChipCategory.values.length,
                  itemBuilder: (context, index) {
                    final category = ChipCategory.values[index];
                    final selected = selectedCategories.contains(category.value);

                    return FilterCard(
                      category: category,
                      selected: selected,
                      onTap: () => toggleCategory(category),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 5),

          // Дополнительные фильтры
          Row(
            children: [
              Expanded(
                child: _CompactFilterCard(
                  icon: Icons.public_rounded,
                  label: 'Только Россия',
                  isSelected: _russiaOnly,
                  onTap: toggleRussiaOnly,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CompactFilterCard(
                  icon: Icons.shopping_cart_rounded,
                  label: 'В продаже',
                  isSelected: _availableOnly,
                  onTap: toggleAvailableOnly,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


Future<void> toggleRussiaOnly() async {
  final previous = _russiaOnly;
  setState(() => _russiaOnly = !_russiaOnly);

  try {
    await FilterService.updateFilters(
      russiaOnly: _russiaOnly,
    );
  } catch (e) {
    if (mounted) {
      setState(() => _russiaOnly = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Не удалось сохранить настройки")),
      );
    }
  }
}

  Future<void> toggleAvailableOnly() async {
    final previous = _availableOnly;
    setState(() => _availableOnly = !_availableOnly);

    try {
      await FilterService.updateFilters(
        availableOnly: _availableOnly,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _availableOnly = previous);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Не удалось сохранить настройки")),
        );
      }
    }
  }

}




class _CompactFilterCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CompactFilterCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CompactFilterCard> createState() => _CompactFilterCardState();
}

class _CompactFilterCardState extends State<_CompactFilterCard> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedScale(
      scale: pressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTapDown: (_) => setState(() => pressed = true),
        onTapUp: (_) {
          setState(() => pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => pressed = false),

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: widget.isSelected ? 12 : 8,
                spreadRadius: widget.isSelected ? 1 : 0,
                offset: const Offset(0, 4),
                color: Colors.black.withOpacity(
                  widget.isSelected ? 0.18 : 0.10,
                ),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 24,
                color: widget.isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
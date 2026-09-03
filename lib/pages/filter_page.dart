import 'package:flutter/material.dart';

import '../../models/chip_category.dart';
import '../../widgets/filter_card.dart';
import '../../services/preference_service.dart';


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
      final preferences = await PreferenceService.getPreferences();
      setState(() {
        selectedCategories
          ..clear()
          ..addAll(preferences);        
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
      await PreferenceService.updatePreferences(
        selectedCategories.toList(),
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
                  onTap: () {
                    setState(() => _russiaOnly = !_russiaOnly);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CompactFilterCard(
                  icon: Icons.shopping_cart_rounded,
                  label: 'В продаже',
                  isSelected: _availableOnly,
                  onTap: () {
                    setState(() => _availableOnly = !_availableOnly);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}


class _CompactFilterCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.5)
                : theme.colorScheme.outlineVariant.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
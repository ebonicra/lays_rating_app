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
    );
  }
}
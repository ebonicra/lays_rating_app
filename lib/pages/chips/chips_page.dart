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
  List<LaysChip> chips = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadChips();
  }

  Future<void> loadChips() async {
    setState(() {
      isLoading = true;
    });

    try {
      final filters = await PreferenceService.getPreferences();
      
      final result = await ChipService.fetchChips(
        categories: filters.categories,
      );

      // Фильтруем на клиенте
      final filtered = result.where((chip) {
        // Фильтр по стране
        if (filters.russiaOnly && !chip.country.toLowerCase().contains('россия')) {
          return false;
        }

        // Фильтр по наличию
        if (filters.availableOnly && !chip.available) {
          return false;
        }

        return true;
      }).toList();

      if (mounted) {
        setState(() {
          chips = filtered;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось загрузить чипсы')),
        );
      }
    }
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
        title: const Text("Рейтинг Lay's"),
      ),
      body: chips.isEmpty
          ? Center(
              child: Text(
                'Нет чипсов с такими фильтрами',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            )
          : ListView.builder(
              itemCount: chips.length,
              itemBuilder: (context, index) {
                return ChipCard(
                  chip: chips[index],
                  onReturn: loadChips,
                );
              },
            ),
    );
  }
}
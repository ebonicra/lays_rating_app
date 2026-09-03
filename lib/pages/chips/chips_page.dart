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

    final categories = await PreferenceService.getPreferences();
    final result = await ChipService.fetchChips(
      categories: categories,
    );

    setState(() {
      chips = result;
      isLoading = false;
    });
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
      body: ListView.builder(
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
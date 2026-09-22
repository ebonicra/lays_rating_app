import 'package:flutter/material.dart';

// Данные для квадратика статистики.
class StatsSquare {
  const StatsSquare({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
}
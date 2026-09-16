import 'package:flutter/material.dart';

// Данные для квадратика статистики.
class StatSquareData {
  const StatSquareData({
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
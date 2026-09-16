import 'package:flutter/material.dart';

String colorName(String color) {
  switch (color) {
    case 'pink':
      return 'Розовый';
    case 'blue':
      return 'Синий';
    case 'black':
      return 'Чёрный';
    default:
      return 'Розовый';
  }
}

String themeName(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'Светлая';
    case ThemeMode.dark:
      return 'Тёмная';
    case ThemeMode.system:
      return 'Системная';
  }
}
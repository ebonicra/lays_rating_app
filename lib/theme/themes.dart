import 'package:flutter/material.dart';
import 'colors.dart';

class AppThemes {
  
  // ----- РОЗОВАЯ ТЕМА -----
  static final pinkLight = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.pink,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.pink,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  static final pinkDark = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.pink,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
  );

  // ----- СИНЯЯ ТЕМА -----
  static final blueLight = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.blue,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  static final blueDark = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
  );

  // ----- ЧЁРНАЯ ТЕМА (всегда тёмная) -----
  static final blackLight = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.black,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE0E0E0),
      onPrimaryContainer: Colors.black,
      secondary: AppColors.black,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
    ).copyWith(
      inversePrimary: Colors.grey.shade700,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.black,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  static final blackDark = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      onPrimary: Colors.black,
      primaryContainer: Color(0xFF2C2C2C),
      onPrimaryContainer: Colors.white,
      secondary: Colors.white,
      onSecondary: Colors.black,
      surface: AppColors.darkSurface,
      onSurface: Colors.white,
    ).copyWith(
      inversePrimary: Colors.grey.shade700,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.black,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
  );

  // ----- ДЕФОЛТНЫЕ (для fallback) -----
  static final light = pinkLight;
  static final dark = pinkDark;
}
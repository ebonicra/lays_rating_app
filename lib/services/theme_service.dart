import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const _keyThemeMode = 'theme_mode';
  static const _keyAccentColor = 'accent_color';

  // Сохранить режим темы
  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode.name);
  }

  // Загрузить режим темы
  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeName = prefs.getString(_keyThemeMode);
    
    switch (modeName) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  // Сохранить акцентный цвет
  static Future<void> saveAccentColor(String color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccentColor, color);
  }

  // Загрузить акцентный цвет
  static Future<String> loadAccentColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccentColor) ?? 'pink';
  }
}
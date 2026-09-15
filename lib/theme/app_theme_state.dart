import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import 'themes.dart';

class AppThemeState extends ChangeNotifier {
  AppThemeState._();
  static final AppThemeState instance = AppThemeState._();

  static const String defaultAccent = 'pink';

  ThemeMode _themeMode = ThemeMode.system;
  String _accentColor = defaultAccent;
  bool _isLoaded = false;

  ThemeMode get themeMode => _themeMode;
  String get accentColor => _accentColor;
  bool get isLoaded => _isLoaded;

  /// Пара (light, dark) для текущего акцента.
  (ThemeData, ThemeData) get themes {
    switch (_accentColor) {
      case 'blue':
        return (AppThemes.blueLight, AppThemes.blueDark);
      case 'black':
        return (AppThemes.blackLight, AppThemes.blackDark);
      case 'pink':
      default:
        return (AppThemes.pinkLight, AppThemes.pinkDark);
    }
  }

  Future<void> load() async {
    try {
      _themeMode = await ThemeService.loadThemeMode();
      _accentColor = await ThemeService.loadAccentColor();
    } catch (e) {
      debugPrint('AppThemeState.load error: $e');
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    try {
      await ThemeService.saveThemeMode(mode);
    } catch (e) {
      debugPrint('AppThemeState.setThemeMode error: $e');
    }
  }

  Future<void> setAccentColor(String color) async {
    if (_accentColor == color) return;
    _accentColor = color;
    notifyListeners();
    try {
      await ThemeService.saveAccentColor(color);
    } catch (e) {
      debugPrint('AppThemeState.setAccentColor error: $e');
    }
  }
}
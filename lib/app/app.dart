import 'package:flutter/material.dart';
import '../pages/auth/auth_check_page.dart';
import '../services/theme_service.dart';
import 'themes.dart';

// Синглтон для хранения состояния темы
class AppThemeState extends ChangeNotifier {
  AppThemeState._();
  static final AppThemeState _instance = AppThemeState._();
  static AppThemeState get instance => _instance;

  ThemeMode _themeMode = ThemeMode.system;
  String _accentColor = 'pink';
  bool _isLoaded = false;

  ThemeMode get themeMode => _themeMode;
  String get accentColor => _accentColor;
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    _themeMode = await ThemeService.loadThemeMode();
    _accentColor = await ThemeService.loadAccentColor();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await ThemeService.saveThemeMode(mode);
    _themeMode = mode;
    notifyListeners();
  }

  Future<void> setAccentColor(String color) async {
    await ThemeService.saveAccentColor(color);
    _accentColor = color;
    notifyListeners();
  }
}

// ===== LAYS APP =====
class LaysApp extends StatefulWidget {
  const LaysApp({super.key});

  @override
  State<LaysApp> createState() => _LaysAppState();
}

class _LaysAppState extends State<LaysApp> {
  final _themeState = AppThemeState.instance;

  @override
  void initState() {
    super.initState();
    _themeState.addListener(_onThemeChanged);
    if (!_themeState.isLoaded) {
      _themeState.load();
    }
  }

  @override
  void dispose() {
    _themeState.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  ThemeData _getTheme(Brightness brightness) {
    switch (_themeState.accentColor) {
      case 'blue':
        return brightness == Brightness.light
            ? AppThemes.blueLight
            : AppThemes.blueDark;
      case 'black':
        return brightness == Brightness.light
            ? AppThemes.blackLight   // ← теперь светлая
            : AppThemes.blackDark;   // ← и тёмная
      case 'pink':
      default:
        return brightness == Brightness.light
            ? AppThemes.pinkLight
            : AppThemes.pinkDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_themeState.isLoaded) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'Lays Rating',
      debugShowCheckedModeBanner: false,

      themeMode: _themeState.themeMode,
      theme: _getTheme(Brightness.light),
      darkTheme: _getTheme(Brightness.dark),

      home: const AuthCheckPage(),
    );
  }
}
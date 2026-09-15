import 'package:flutter/material.dart';

import 'package:lays_rating/theme/app_theme_scope.dart';
import 'package:lays_rating/theme/app_theme_state.dart';
import 'package:lays_rating/pages/auth/auth_check_page.dart';


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
    if (!_themeState.isLoaded) _themeState.load();
  }

  @override
  Widget build(BuildContext context) {
    return AppThemeScope(
      state: _themeState,
      child: AnimatedBuilder(
        animation: _themeState,
        builder: (context, _) {
          final (light, dark) = _themeState.themes;

          return MaterialApp(
            title: 'Lays Rating',
            debugShowCheckedModeBanner: false,
            themeMode: _themeState.themeMode,
            theme: light,
            darkTheme: dark,
            home: _themeState.isLoaded
                ? const AuthCheckPage()
                : const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
          );
        },
      ),
    );
  }
}
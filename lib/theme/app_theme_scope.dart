import 'package:flutter/material.dart';
import 'app_theme_state.dart';

class AppThemeScope extends InheritedNotifier<AppThemeState> {
  const AppThemeScope({
    super.key,
    required AppThemeState state,
    required super.child,
  }) : super(notifier: state);

  static AppThemeState of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppThemeScope>();
    assert(scope != null, 'AppThemeScope не найден в дереве');
    return scope!.notifier!;
  }
}
import 'package:flutter/material.dart';

import 'package:lays_rating/theme/app_theme_scope.dart';
import 'package:lays_rating/utils/theme_names.dart';
import 'package:lays_rating/widgets/profile/appearance/color_wheel_dialog.dart';
import 'package:lays_rating/widgets/profile/appearance/theme_wheel_dialog.dart';

/// Карточка с настройками внешнего вида: цвет приложения и тема
class ProfileAppearanceCard extends StatelessWidget {
  const ProfileAppearanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final themeState = AppThemeScope.of(context);

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Цвет приложения'),
            subtitle: Text(colorName(themeState.accentColor)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => ColorWheelDialog(
                  currentColor: themeState.accentColor,
                  onColorChanged: (color) {
                    themeState.setAccentColor(color);
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6_rounded),
            title: const Text('Тема приложения'),
            subtitle: Text(themeName(themeState.themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => ThemeWheelDialog(
                  currentTheme: themeState.themeMode,
                  onThemeChanged: (mode) {
                    themeState.setThemeMode(mode);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
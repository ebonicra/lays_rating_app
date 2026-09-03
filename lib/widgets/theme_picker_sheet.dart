import 'package:flutter/material.dart';

class ThemePickerSheet extends StatefulWidget {
  final ThemeMode currentTheme;
  final ValueChanged<ThemeMode> onThemeChanged;

  const ThemePickerSheet({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  State<ThemePickerSheet> createState() => _ThemePickerSheetState();
}

class _ThemePickerSheetState extends State<ThemePickerSheet> {
  late ThemeMode _selectedTheme;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.currentTheme;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Полоска сверху
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Выбери тему',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _ThemeOption(
            icon: Icons.light_mode_rounded,
            emoji: '☀️',
            label: 'Светлая',
            subtitle: 'Всегда светлая тема',
            isSelected: _selectedTheme == ThemeMode.light,
            onTap: () {
              setState(() => _selectedTheme = ThemeMode.light);
              widget.onThemeChanged(ThemeMode.light);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),

          _ThemeOption(
            icon: Icons.dark_mode_rounded,
            emoji: '🌙',
            label: 'Тёмная',
            subtitle: 'Всегда тёмная тема',
            isSelected: _selectedTheme == ThemeMode.dark,
            onTap: () {
              setState(() => _selectedTheme = ThemeMode.dark);
              widget.onThemeChanged(ThemeMode.dark);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),

          _ThemeOption(
            icon: Icons.phone_android_rounded,
            emoji: '📱',
            label: 'Системная',
            subtitle: 'Как в настройках телефона',
            isSelected: _selectedTheme == ThemeMode.system,
            onTap: () {
              setState(() => _selectedTheme = ThemeMode.system);
              widget.onThemeChanged(ThemeMode.system);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String emoji;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? theme.colorScheme.primaryContainer.withOpacity(0.5)
              : theme.colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.5)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
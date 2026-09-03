import 'package:flutter/material.dart';
import '../app/colors.dart';

class ColorPickerSheet extends StatefulWidget {
  final String currentColor;
  final ValueChanged<String> onColorChanged;

  const ColorPickerSheet({
    super.key,
    required this.currentColor,
    required this.onColorChanged,
  });

  @override
  State<ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<ColorPickerSheet> {
  // Локальное состояние — обновляется сразу при тапе
  late String _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.currentColor;
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
            'Выбери цвет',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _ColorOption(
            color: AppColors.pink,
            label: 'Розовый',
            emoji: '💗',
            isSelected: _selectedColor == 'pink',
            onTap: () {
              setState(() => _selectedColor = 'pink');
              widget.onColorChanged('pink');
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),

          _ColorOption(
            color: AppColors.blue,
            label: 'Синий',
            emoji: '💙',
            isSelected: _selectedColor == 'blue',
            onTap: () {
              setState(() => _selectedColor = 'blue');
              widget.onColorChanged('blue');
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),

          _ColorOption(
            color: AppColors.black,
            label: 'Чёрный',
            emoji: '🖤',
            isSelected: _selectedColor == 'black',
            onTap: () {
              setState(() => _selectedColor = 'black');
              widget.onColorChanged('black');
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.label,
    required this.emoji,
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
              ? color.withOpacity(0.1)
              : theme.colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: isSelected ? color.withOpacity(0.5) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }
}
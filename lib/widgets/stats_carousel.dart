import 'package:flutter/material.dart';

/// Данные для квадратика статистики
class StatSquareData {
  final IconData icon;
  final String label;
  final String value;

  const StatSquareData({
    required this.icon,
    required this.label,
    required this.value,
  });
}

/// Квадратная карточка статистики
class StatSquare extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const StatSquare({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        width: 90,
        height: 90,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: accentColor),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// /// Бесконечная горизонтальная карусель статистики
class InfiniteStatsCarousel extends StatefulWidget {
  final List<StatSquareData> items;

  const InfiniteStatsCarousel({
    super.key,
    required this.items,
  });

  @override
  State<InfiniteStatsCarousel> createState() => InfiniteStatsCarouselState();
}

class InfiniteStatsCarouselState extends State<InfiniteStatsCarousel> {
  late PageController _controller;

  static const int _multiplier = 1000;
  late final int _totalPages = widget.items.length * _multiplier;
  late final int _startPage = _totalPages ~/ 2;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: _startPage,
      viewportFraction: 0.33,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Листаем влево
  void _goLeft() {
    _controller.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // Листаем вправо
  void _goRight() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          itemCount: _totalPages,
          itemBuilder: (context, index) {
            final realIndex = index % widget.items.length;
            final item = widget.items[realIndex];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: StatSquare(
                icon: item.icon,
                label: item.label,
                value: item.value,
              ),
            );
          },
        ),

        // Стрелка влево
        Positioned(
          left: 2,
          top: 0,
          bottom: 0,
          child: Center(
            child: _ArrowButton(
              isLeft: true,
              onTap: _goLeft,
            ),
          ),
        ),

        // Стрелка вправо
        Positioned(
          right: 2,
          top: 0,
          bottom: 0,
          child: Center(
            child: _ArrowButton(
              isLeft: false,
              onTap: _goRight,
            ),
          ),
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final bool isLeft;
  final VoidCallback onTap;

  const _ArrowButton({
    required this.isLeft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isLeft
              ? Icons.chevron_left_rounded
              : Icons.chevron_right_rounded,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
    );
  }
}
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

/// Бесконечная горизонтальная карусель статистики
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
  bool _showHint = true;

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

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showHint = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        if (_showHint) ...[
          Positioned(
            left: 2,
            top: 0,
            bottom: 0,
            child: Center(
              child: AnimatedOpacity(
                opacity: _showHint ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: const _PulsingArrow(isLeft: true),
              ),
            ),
          ),
          Positioned(
            right: 2,
            top: 0,
            bottom: 0,
            child: Center(
              child: AnimatedOpacity(
                opacity: _showHint ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: const _PulsingArrow(isLeft: false),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PulsingArrow extends StatefulWidget {
  final bool isLeft;

  const _PulsingArrow({required this.isLeft});

  @override
  State<_PulsingArrow> createState() => _PulsingArrowState();
}

class _PulsingArrowState extends State<_PulsingArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.isLeft
              ? Icons.chevron_left_rounded
              : Icons.chevron_right_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
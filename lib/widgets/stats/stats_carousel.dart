import 'package:flutter/material.dart';

import 'package:lays_rating/models/stat_square_data.dart';
import 'package:lays_rating/widgets/stats/stat_square.dart';

/// Бесконечная горизонтальная карусель статистики.
class InfiniteStatsCarousel extends StatefulWidget {
  const InfiniteStatsCarousel({
    super.key,
    required this.items,
  });

  final List<StatSquareData> items;

  @override
  State<InfiniteStatsCarousel> createState() => InfiniteStatsCarouselState();
}

class InfiniteStatsCarouselState extends State<InfiniteStatsCarousel> {
  static const int _multiplier = 1000;

  late PageController _controller;
  late final int _totalPages;
  late final int _startPage;

  @override
  void initState() {
    super.initState();
    _totalPages = widget.items.length * _multiplier;
    _startPage = _totalPages ~/ 2;
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

  void _goLeft() {
    _controller.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _goRight() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          itemCount: _totalPages,
          itemBuilder: (context, index) {
            final realIndex = index % widget.items.length;
            final item = widget.items[realIndex];

            return StatSquare(
              icon: item.icon,
              label: item.label,
              value: item.value,
              onTap: item.onTap,
            );
          },
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Center(
            child: _ArrowButton(isLeft: true, onTap: _goLeft),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: Center(
            child: _ArrowButton(isLeft: false, onTap: _goRight),
          ),
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.isLeft,
    required this.onTap,
  });

  final bool isLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isLeft ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
          color: colorScheme.primary,
          size: 20,
        ),
      ),
    );
  }
}
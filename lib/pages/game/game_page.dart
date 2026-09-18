import 'dart:math' as math;
import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

enum ChipType {
  normal,
  golden,
  poop,
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _gameController;

  double _playerX = 0.5;
  double _packWidth = 100;
  double _packHeight = 70;
  int _score = 0;
  final List<_FallingChip> _chips = [];
  double _gameSpeed = 0.5;

  @override
  void initState() {
    super.initState();
    _gameController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateGame);

    _startSpawning();
    _gameController.repeat();
  }

  @override
  void dispose() {
    _gameController.dispose();
    super.dispose();
  }

  // Спавн нескольких чипсов за раз
  void _startSpawning() {
    // Интервал зависит от скорости игры
    final interval = (1200 / _gameSpeed).toInt();
    
    Future.delayed(Duration(milliseconds: interval), () {
      if (mounted) {
        setState(() {
          // Спавним ТОЛЬКО ОДИН чипс за раз
          _chips.add(_FallingChip(
            x: math.Random().nextDouble(),
            y: -0.05,
            speed: (0.015 + math.Random().nextDouble() * 0.01) * _gameSpeed,
            type: _getRandomChipType(),
          ));
        });
        _startSpawning(); // рекурсивно продолжаем
      }
    });
  }

  // Случайный тип чипса
  ChipType _getRandomChipType() {
    final random = math.Random().nextDouble();
    if (random < 0.08) {
      return ChipType.golden; // 8% золотой
    } else if (random < 0.23) {
      return ChipType.poop; // 15% какашка
    } else {
      return ChipType.normal; // 77% обычный
    }
  }

  // Обновление позиций чипсов
  void _updateGame() {
    if (!mounted) return;

    setState(() {
      for (final chip in _chips) {
        chip.y += chip.speed;
      }

      for (final chip in _chips.toList()) {
        if (chip.y >= 1.0) {
          // Чипс достиг низа
          if (_isCaught(chip.x)) {
            // Поймали!
            switch (chip.type) {
              case ChipType.normal:
                _score += 1;
                _packWidth += 0.5;
                _packHeight += 0.4;
                break;
              case ChipType.golden:
                _score += 10;
                _packWidth += 1.5;
                _packHeight += 1.0;
                break;
              case ChipType.poop:
                _score -= 5;
                _packWidth -= 1.0;
                _packHeight -= 0.8;
                if (_packWidth < 70) _packWidth = 70;
                if (_packHeight < 50) _packHeight = 50;
                break;
            }
          } else {
            // Упустили!
            switch (chip.type) {
              case ChipType.normal:
                _score -= 1; // ← минус за упущенный
                break;
              case ChipType.golden:
                _score -= 5; // ← минус за упущенный золотой
                break;
              case ChipType.poop:
                // Какашку упустили — это хорошо!
                _score += 3; // ← бонус, что не поймали
                break;
            }
          }
          _gameSpeed += 0.003;
          _chips.remove(chip);
        }
      }
    });
  }

  // Проверка, поймала ли пачка чипс
  bool _isCaught(double chipX) {
    final packLeft = _playerX - _packWidth / (MediaQuery.of(context).size.width * 2);
    final packRight = _playerX + _packWidth / (MediaQuery.of(context).size.width * 2);
    return chipX >= packLeft && chipX <= packRight;
  }

  // Движение пачки
  void _movePlayer(Offset position) {
    final width = MediaQuery.of(context).size.width;
    setState(() {
      _playerX = (position.dx / width).clamp(0.1, 0.9);
    });
  }

  // Получить эмодзи по типу
  String _getChipEmoji(ChipType type) {
    switch (type) {
      case ChipType.normal:
        return '🍟';
      case ChipType.golden:
        return '⭐';
      case ChipType.poop:
        return '💩';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Игра'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                '$_score',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          _movePlayer(details.localPosition);
        },
        onTapDown: (details) {
          _movePlayer(details.localPosition);
        },
        child: Stack(
          children: [
            // Игровое поле
            Container(
              color: Theme.of(context).colorScheme.onPrimary,
            ),

            // Падающие чипсы
            ..._chips.map((chip) {
              return Positioned(
                left: screenWidth * chip.x - 15,
                top: screenHeight * chip.y - 15,
                child: Text(
                  _getChipEmoji(chip.type),
                  style: const TextStyle(fontSize: 30),
                ),
              );
            }),

            // Пачка чипсов
            Positioned(
              left: screenWidth * _playerX - _packWidth / 2,
              bottom: 10,
              child: _ChipsPack(
                width: _packWidth,
                height: _packHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Падающий чипс
class _FallingChip {
  final double x;
  double y;
  final double speed;
  final ChipType type;

  _FallingChip({
    required this.x,
    required this.y,
    required this.speed,
    required this.type,
  });
}

/// Пачка чипсов
class _ChipsPack extends StatelessWidget {
  final double width;
  final double height;

  const _ChipsPack({
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/chip_bag.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:lays_rating/services/game_service.dart';
import 'package:lays_rating/widgets/game/game_over_overlay.dart';

enum ChipType { normal, golden, poop }

const Map<ChipType, List<String>> chipImages = {
  ChipType.normal: [
    'assets/images/chips/chip_1.png',
    'assets/images/chips/chip_2.png',
    'assets/images/chips/chip_3.png',
    'assets/images/chips/chip_4.png',
    'assets/images/chips/chip_5.png',
    'assets/images/chips/chip_6.png',
    'assets/images/chips/chip_8.png',
    'assets/images/chips/chip_9.png',
  ],
  ChipType.golden: [],
  ChipType.poop: [],
};

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  // ===== Константы =====
  static const double _basePackWidth = 100;
  static const double _basePackHeight = 70;
  static const int _spawnIntervalMs = 1200;
  static const double _packBottomOffset = 10;
  static const double _chipSize = 40;
  static const bool _debugMode = false;

  /// Насколько глубоко чипс «заходит» в пачку, прежде чем исчезнуть.
  /// 0.0 — верх пачки, 0.5 — середина, 1.0 — низ.
  static const double _catchDepth = 0.3;
  static const double _catchWidthFactor = 0.75;


  // ===== Контроллер =====
  late AnimationController _gameController;

  // ===== Состояние =====
  double _playerX = 0.5;
  int _score = 0;
  double _gameSpeed = 0.7;
  bool _isGameOver = false;
  final List<_FallingChip> _chips = [];

  /// Реальная высота игрового поля (Stack в body).
  double _fieldHeight = 0;
  double _fieldWidth = 0;

  // ===== Сохранение рекорда =====
  bool _isSaving = false;
  int? _bestScore;
  bool _isNewRecord = false;

  // static const int _spawnIntervalMs = 550;
  // static const double _chipSize = 40;

  // ===== Предзагрузка =====
  bool _precached = false;

  // ===== Геттеры =====
  double get _packWidth => _basePackWidth + _score * 1;
  double get _packHeight => _basePackHeight + _score * 0.5;

  bool _isCaughtX(double chipX) {
    if (_fieldWidth <= 0) return false;
    final effectiveWidth = _packWidth * _catchWidthFactor;
    final packLeft = _playerX - effectiveWidth / (_fieldWidth * 2);
    final packRight = _playerX + effectiveWidth / (_fieldWidth * 2);
    return chipX >= packLeft && chipX <= packRight;
  }

  /// Y-координата (доля от высоты поля) линии поимки.
  /// Считается от верха поля.
  double _catchLine() {
    if (_fieldHeight <= 0) return 1.0;
    // Верх пачки в пикселях от низа поля
    final packTopFromBottom = _packBottomOffset + _packHeight;
    // Доля от низа → доля от верха
    final packTop = 1.0 - packTopFromBottom / _fieldHeight;
    // Спускаемся на глубину _catchDepth от высоты пачки
    final depth = (_packHeight * _catchDepth) / _fieldHeight;
    return (packTop + depth).clamp(0.0, 1.0);
  }

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;

    for (final images in chipImages.values) {
      for (final path in images) {
        precacheImage(AssetImage(path), context);
      }
    }
    precacheImage(
      const AssetImage('assets/images/chip_bag.png'),
      context,
    );
  }

  @override
  void dispose() {
    _gameController.dispose();

    if (!_isGameOver && _score > 0) {
      // ignore: unawaited_futures
      GameService.saveScore(_score);
    }

    super.dispose();
  }

  // ===== Спавн =====
  void _startSpawning() {
    final interval = (_spawnIntervalMs / _gameSpeed).toInt();

    Future.delayed(Duration(milliseconds: interval), () {
      if (!mounted || _isGameOver) return;

      // LayoutBuilder ещё не отрисовался — подождём немного и попробуем снова
      if (_fieldWidth <= 0) {
        _startSpawning();
        return;
      }

      final type = _getRandomChipType();
      final images = chipImages[type] ?? const [];
      final imagePath = images.isEmpty
          ? null
          : images[math.Random().nextInt(images.length)];

      // Ограничиваем X в пикселях с учётом ширины чипса
      final chipHalf = (_chipSize / 2) / _fieldWidth;
      final minX = chipHalf + 0.02;
      final maxX = 1.0 - chipHalf - 0.02;
      final x = minX + math.Random().nextDouble() * (maxX - minX);

      final chip = _FallingChip(
        id: DateTime.now().microsecondsSinceEpoch,
        x: x,
        y: -0.05,
        speed: (0.010 + math.Random().nextDouble() * 0.007) * _gameSpeed,
        type: type,
        imagePath: imagePath,
      );

      setState(() {
        _chips.add(chip);
      });

      if (_debugMode) {
        debugPrint('SPAWN id=${chip.id} type=${chip.type.name} '
            'x=${x.toStringAsFixed(2)}');
      }

      _startSpawning();
    });
  }

  ChipType _getRandomChipType() {
    final r = math.Random().nextDouble();
    if (r < 0.08) return ChipType.golden;
    if (r < 0.23) return ChipType.poop;
    return ChipType.normal;
  }

  // ===== Обновление =====
  void _updateGame() {
    if (!mounted || _isGameOver) return;
    if (_fieldHeight <= 0) return;

    final catchLine = _catchLine();
    bool endGame = false;

    setState(() {
      for (final chip in _chips) {
        chip.y += chip.speed;
      }

      _chips.removeWhere((chip) {
        if (chip.y >= 1.0) {
          _handleMissed(chip);
          return true;
        }

        if (chip.y >= catchLine && _isCaughtX(chip.x)) {
          if (chip.type == ChipType.poop) {
            endGame = true;
            return true;
          }
          _handleCaught(chip);
          return true;
        }

        return false;
      });
    });

    if (endGame) {
      _endGame();
    }
  }

  void _handleCaught(_FallingChip chip) {
    switch (chip.type) {
      case ChipType.normal:
        _score += 1;
        break;
      case ChipType.golden:
        _score += 5;
        break;
      case ChipType.poop:
        break;
    }
    _gameSpeed += 0.005;
  }

  void _handleMissed(_FallingChip chip) {
    switch (chip.type) {
      case ChipType.normal:
        _score = (_score - 1).clamp(0, 1 << 31);
        break;
      case ChipType.golden:
        _score = (_score - 5).clamp(0, 1 << 31);
        break;
      case ChipType.poop:
        break;
    }
    // _gameSpeed += 0.003;
  }


  void _movePlayer(Offset position) {
    if (_isGameOver) return;
    if (_fieldWidth <= 0) return;
    setState(() {
      _playerX = (position.dx / _fieldWidth).clamp(0.1, 0.9);
    });
  }

  // ===== Конец игры =====
  Future<void> _endGame() async {
    _isGameOver = true;
    _gameController.stop();
    _chips.clear();

    setState(() {});

    if (_score > 0) {
      await _saveScore();
    }
  }

  Future<void> _saveScore() async {
    setState(() => _isSaving = true);

    try {
      final result = await GameService.saveScore(_score);
      if (!mounted) return;
      setState(() {
        _bestScore = result.bestScore;
        _isNewRecord = result.isNewRecord;
        _isSaving = false;
      });
    } catch (e) {
      debugPrint('GamePage._saveScore error: $e');
      if (!mounted) return;
      setState(() {
        _bestScore = null;
        _isNewRecord = false;
        _isSaving = false;
      });
    }
  }

  void _restartGame() {
    setState(() {
      _score = 0;
      _playerX = 0.5;
      _gameSpeed = 0.5;
      _isGameOver = false;
      _isSaving = false;
      _bestScore = null;
      _isNewRecord = false;
      _chips.clear();
    });

    _startSpawning();
    _gameController.repeat();
  }

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

  // ===== Build =====
  @override
  Widget build(BuildContext context) {
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          _fieldHeight = constraints.maxHeight;
          _fieldWidth = constraints.maxWidth;

          final screenWidth = _fieldWidth;
          final screenHeight = _fieldHeight;
          final catchLine = _catchLine();

          return Stack(
            children: [
              GestureDetector(
                onHorizontalDragUpdate: (details) {
                  _movePlayer(details.localPosition);
                },
                onTapDown: (details) {
                  _movePlayer(details.localPosition);
                },
                child: Stack(
                  children: [
                    Container(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),

                    // Отладочная красная линия поимки
                    if (_debugMode)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: screenHeight * catchLine,
                        child: Container(
                          height: 2,
                          color: Colors.red,
                        ),
                      ),

                    // Чипсы
                    ..._chips.map((chip) {
                      return Positioned(
                        left: screenWidth * chip.x - _chipSize / 2,
                        top: screenHeight * chip.y - _chipSize / 2,
                        child: chip.imagePath != null
                            ? Image.asset(
                                chip.imagePath!,
                                width: _chipSize,
                                height: _chipSize,
                                fit: BoxFit.contain,
                              )
                            : Text(
                                _getChipEmoji(chip.type),
                                style: const TextStyle(fontSize: 30),
                              ),
                      );
                    }),

                    // Пачка
                    Positioned(
                      left: screenWidth * _playerX - _packWidth / 2,
                      bottom: _packBottomOffset,
                      child: _ChipsPack(
                        width: _packWidth,
                        height: _packHeight,
                      ),
                    ),
                  ],
                ),
              ),

              if (_isGameOver)
                GameOverOverlay(
                  score: _score,
                  bestScore: _bestScore,
                  isNewRecord: _isNewRecord,
                  isSaving: _isSaving,
                  onPlayAgain: _restartGame,
                ),
            ],
          );
        },
      ),
    );
  }
}

// ===== Падающий чипс =====
class _FallingChip {
  final int id;
  final double x;
  double y;
  final double speed;
  final ChipType type;
  final String? imagePath;

  _FallingChip({
    required this.id,
    required this.x,
    required this.y,
    required this.speed,
    required this.type,
    this.imagePath,
  });
}

// ===== Пачка =====
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
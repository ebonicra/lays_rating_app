import 'package:flutter/material.dart';

import 'package:lays_rating/models/chip.dart';
import 'package:lays_rating/models/chip_preference.dart';

import 'package:lays_rating/widgets/rating_stars.dart';
import 'package:lays_rating/widgets/comments_section.dart';
// import 'package:lays_rating/widgets/comments_page.dart'

class ChipDetailsView extends StatefulWidget {
  final LaysChip chip;
  final ChipPreference preference;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onFavoriteChanged;
  final VoidCallback onTriedChanged;

  const ChipDetailsView({
    super.key,
    required this.chip,
    required this.preference,
    required this.onRatingChanged,
    required this.onFavoriteChanged,
    required this.onTriedChanged,
  });

  @override
  State<ChipDetailsView> createState() => _ChipDetailsViewState();
}

class _ChipDetailsViewState extends State<ChipDetailsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _flipController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }


  void _toggleFlip() {
    if (_isFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chip = widget.chip;
    final preference = widget.preference;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ПЕРЕВОРАЧИВАЮЩАЯСЯ КАРТОЧКА
          GestureDetector(
            onTap: _toggleFlip,
            child: AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, child) {
                final isFront = _flipAnimation.value <= 0.5;

                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_flipAnimation.value * 3.14159),
                  child: isFront
                      ? Center(child: _buildFrontCard(theme, chip))
                      : Center(child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(3.14159),
                          child: _buildBackCard(theme, chip),
                        )),
                );
              },
            ),
          ),
          const SizedBox(height: 24),


          // НАЗВАНИЕ
          Center(
            child: Text(
              chip.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),

          // ОПИСАНИЕ
          Text(
            chip.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
              fontSize: 14,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          // РЕЙТИНГ
          _RatingSection(
            chip: chip,
            preference: preference,
            onRatingChanged: widget.onRatingChanged,
          ),
          const SizedBox(height: 20),

          // КНОПКА ЛЮБИМЧИК
          _MiniActionButton(
            icon: Icons.favorite_outline_rounded,
            label: 'Любимчик',
            active: preference.isFavorite,
            activeColor: Color(0xFFFF4081),
            onTap: widget.onFavoriteChanged,
          ),
          const SizedBox(height: 8),

          // КНОПКА ПРОБОВАЛ
          _MiniActionButton(
            icon: Icons.fastfood_rounded,
            label: 'Пробовал',
            active: preference.isTried,
            activeColor: Color(0xFF00E676),
            onTap: widget.onTriedChanged,
          ),
          const SizedBox(height: 24),

          // КОММЕНТАРИИ
          CommentsSection(chipId: chip.id),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Лицевая сторона — картинка
  Widget _buildFrontCard(ThemeData theme, LaysChip chip) {
    return Hero(
      tag: chip.id,
      child: Container(
        height: 320,
        width: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.2),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Картинка
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                "assets/images/chips/${chip.category.name}/${chip.imagePath}",
                height: 320,
                width: 320,
                fit: BoxFit.cover,
              ),
            ),
            // Подсказка "нажми"
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black.withOpacity(0.5),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                    SizedBox(width: 3),
                    Text(
                      'Детали',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Обратная сторона — информация
  Widget _buildBackCard(ThemeData theme, LaysChip chip) {
    return Container(
      height: 320,
      width: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.2),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Информация по центру
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 36,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(theme, Icons.category_rounded, 'Категория', _getCategoryName(chip.category.name)),
                  const SizedBox(height: 12),
                  _buildInfoRow(theme, Icons.calendar_today_rounded, 'Год выпуска', chip.releaseYear.toString()),
                  const SizedBox(height: 12),
                  _buildInfoRow(theme, Icons.public_rounded, 'Страна', chip.country),
                  const SizedBox(height: 12),
                  _buildInfoRow(theme, Icons.collections_bookmark_rounded, 'Коллекция', chip.collection),
                  const SizedBox(height: 12),
                  _buildInfoRow(theme, Icons.shopping_cart_rounded, 'Наличие', chip.available ? 'В продаже' : 'Снят с продажи'),
                ],
              ),
            ),
          ),
          // Подсказка "назад" внизу справа
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black.withOpacity(0.5),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                  SizedBox(width: 3),
                  Text(
                    'Назад',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildInfoRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: theme.colorScheme.surface.withOpacity(0.7),
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  String _getCategoryName(String category) {
    switch (category) {
      case 'maxx':
        return 'Maxx';
      case 'stix':
        return 'Stix';
      case 'classic':
        return 'Классические';
      case 'corrugated':
        return 'Рифленые';
      default:
        return category;
    }
  }
}


/// Блок: Твоя оценка + Средний рейтинг
class _RatingSection extends StatelessWidget {
  final LaysChip chip;
  final ChipPreference preference;
  final ValueChanged<int> onRatingChanged;

  const _RatingSection({
    required this.chip,
    required this.preference,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Твоя оценка — слева
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Твоя оценка:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              RatingStars(
                rating: preference.rating ?? 0,
                onChanged: onRatingChanged,
                starSize: 30,
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Средняя оценка — справа на подложке
        Expanded(
          flex: 2,
          child: _RatingBadge(rating: chip.rating.average, count: chip.rating.count),
        ),
      ],
    );
  }
}



/// Цветная плашка со средней оценкой
class _RatingBadge extends StatelessWidget {
  final double rating;
  final int count;

  const _RatingBadge({required this.rating, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: _getRatingColors(rating),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _getRatingColors(rating)[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '($count ${_getRatingWord(count)})',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Возвращает цвета градиента в зависимости от рейтинга (усиленный градиент)
  List<Color> _getRatingColors(double rating) {
    // Насыщенные цвета с усиленным контрастом
    const Color gold = Color(0xFFFFD700);
    const Color brightGreen = Color(0xFF00E676);
    const Color darkGreen = Color(0xFF1B5E20);
    const Color lightGreen = Color(0xFFAED581);
    const Color yellow = Color(0xFFFFEB3B);
    const Color deepYellow = Color(0xFFFFC107);
    const Color orange = Color(0xFFFF9800);
    const Color deepOrange = Color(0xFFE65100);
    const Color redOrange = Color(0xFFFF5722);
    const Color red = Color(0xFFD32F2F);
    const Color darkRed = Color(0xFFB71C1C);
    const Color grey = Color(0xFF757575);
    const Color darkGrey = Color(0xFF212121);

    if (rating >= 4.75) {
      final t = (rating - 4.75) / 0.25;
      return [
        Color.lerp(gold, brightGreen, t)!,
        Color.lerp(gold, darkGreen, t)!,
      ];
    } else if (rating >= 4.25) {
      final t = (rating - 4.25) / 0.5;
      return [
        Color.lerp(brightGreen, lightGreen, t)!,
        Color.lerp(darkGreen, lightGreen, t)!,
      ];
    } else if (rating >= 3.75) {
      final t = (rating - 3.75) / 0.5;
      return [
        Color.lerp(lightGreen, yellow, t)!,
        Color.lerp(darkGreen, yellow, t)!,
      ];
    } else if (rating >= 3.25) {
      final t = (rating - 3.25) / 0.5;
      return [
        Color.lerp(yellow, deepYellow, t)!,
        Color.lerp(yellow, orange, t)!,
      ];
    } else if (rating >= 2.75) {
      final t = (rating - 2.75) / 0.5;
      return [
        Color.lerp(deepYellow, orange, t)!,
        Color.lerp(orange, deepOrange, t)!,
      ];
    } else if (rating >= 2.25) {
      final t = (rating - 2.25) / 0.5;
      return [
        Color.lerp(orange, redOrange, t)!,
        Color.lerp(deepOrange, redOrange, t)!,
      ];
    } else if (rating >= 1.75) {
      final t = (rating - 1.75) / 0.5;
      return [
        Color.lerp(redOrange, red, t)!,
        Color.lerp(redOrange, darkRed, t)!,
      ];
    } else if (rating >= 1.25) {
      final t = (rating - 1.25) / 0.5;
      return [
        Color.lerp(red, darkRed, t)!,
        Color.lerp(darkRed, grey, t)!,
      ];
    } else if (rating >= 0.75) {
      final t = (rating - 0.75) / 0.5;
      return [
        Color.lerp(darkRed, grey, t)!,
        Color.lerp(darkRed, darkGrey, t)!,
      ];
    } else if (rating >= 0.25) {
      final t = (rating - 0.25) / 0.5;
      return [
        Color.lerp(grey, darkGrey, t)!,
        Color.lerp(darkGrey, Colors.black, t)!,
      ];
    } else {
      return [darkGrey, Colors.black];
    }
  }

  String _getRatingWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'оценка';
    if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return 'оценки';
    }
    return 'оценок';
  }

}


class _MiniActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _MiniActionButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  State<_MiniActionButton> createState() => _MiniActionButtonState();
}

class _MiniActionButtonState extends State<_MiniActionButton> {
  bool _pressed = false;

  // Future<void> _handleTap() async {
  //   setState(() => _pressed = true);
  //   await Future.delayed(const Duration(milliseconds: 200));
  //   if (mounted) setState(() => _pressed = false);
  //   widget.onTap();
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      // onTap: _handleTap,
      child: AnimatedScale(
        scale: _pressed ? 0.80 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (value) {
            setState(() => _pressed = value);
          },
          borderRadius: BorderRadius.circular(16),

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: widget.active
                  ? theme.colorScheme.inversePrimary.withOpacity(0.8)
                  : theme.colorScheme.background,
              border: Border.all(
                color: widget.active
                    ? theme.colorScheme.inversePrimary
                    : theme.colorScheme.outlineVariant,
              ),
              boxShadow: widget.active
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.inversePrimary.withOpacity(0.8),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: theme.colorScheme.outlineVariant.withOpacity(0.8),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 20,
                  color: widget.active
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.active
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
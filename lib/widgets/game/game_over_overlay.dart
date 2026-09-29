import 'package:flutter/material.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    super.key,
    required this.score,
    required this.bestScore,
    required this.isNewRecord,
    required this.isSaving,
    required this.onPlayAgain,
  });

  final int score;
  final int? bestScore;
  final bool isNewRecord;
  final bool isSaving;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: Colors.black.withOpacity(0.55),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 360),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Игра окончена',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Итоговый счёт
              Text(
                '$score',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'очков',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),

              const SizedBox(height: 20),

              // Рекорд
              if (isNewRecord)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('🏆', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 6),
                      Text(
                        'Новый рекорд!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                )
              else if (bestScore != null)
                Text(
                  'Твой рекорд: $bestScore',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

              if (isSaving) ...[
                const SizedBox(height: 12),
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],

              const SizedBox(height: 24),

              // Кнопки
              Row(
                children: [
                  // Expanded(
                  //   child: OutlinedButton(
                  //     onPressed: isSaving ? null : onExit,
                  //     style: OutlinedButton.styleFrom(
                  //       padding: const EdgeInsets.symmetric(vertical: 14),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //     ),
                  //     child: const Text('Выйти'),
                  //   ),
                  // ),
                  // const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: isSaving ? null : onPlayAgain,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Играть снова'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
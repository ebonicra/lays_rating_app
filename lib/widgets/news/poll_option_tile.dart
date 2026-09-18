import 'package:flutter/material.dart';

import 'package:lays_rating/models/poll.dart';

/// Вариант ответа в опросе новости
class PollOptionTile extends StatelessWidget {
  const PollOptionTile({
    super.key,
    required this.option,
    required this.totalVotes,
    required this.isMyVote,
    required this.hasVoted,
    required this.onTap,
  });

  final PollOption option;
  final int totalVotes;
  final bool isMyVote;
  final bool hasVoted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent =
        totalVotes > 0 ? (option.votes / totalVotes * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isMyVote
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant.withOpacity(0.3),
              width: isMyVote ? 2 : 1,
            ),
            color: isMyVote
                ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                : Colors.transparent,
          ),
          child: Stack(
            children: [
              if (hasVoted)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: percent / 100,
                        child: Container(
                          color: theme.colorScheme.primary.withOpacity(0.15),
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option.text,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isMyVote ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (hasVoted) ...[
                      const SizedBox(width: 8),
                      Text(
                        '$percent%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isMyVote
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                    if (isMyVote) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
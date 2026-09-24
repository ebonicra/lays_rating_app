import 'package:flutter/material.dart';

import 'package:lays_rating/models/poll.dart';

/// Вариант ответа в опросе новости
class PollOptionTile extends StatefulWidget {
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
  State<PollOptionTile> createState() => _PollOptionTileState();
}

class _PollOptionTileState extends State<PollOptionTile> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final option = widget.option;
    final isMyVote = widget.isMyVote;
    final hasVoted = widget.hasVoted;
    final percent = widget.totalVotes > 0
        ? (option.votes / widget.totalVotes * 100).round()
        : 0;

    const radius = 20.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            borderRadius: BorderRadius.circular(radius),
            splashColor: theme.colorScheme.primary.withOpacity(0.08),
            highlightColor: Colors.transparent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                  width: 1,
                ),
                color: isMyVote
                    ? theme.colorScheme.primaryContainer.withOpacity(0.8)
                    : Colors.transparent,
              ),
              child: Stack(
                children: [
                  if (hasVoted)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(radius - 1),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedFractionallySizedBox(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                            widthFactor: percent / 100,
                            child: Container(
                              color: theme.colorScheme.primary
                                  .withOpacity(0.15),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option.text,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.1,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        if (hasVoted) ...[
                          Text(
                            '$percent%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isMyVote
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                        if (isMyVote) ...[
                          const SizedBox(width: 6),
                          SizedBox(
                            height: 16,
                            child: Icon(Icons.check_circle_rounded, size: 14),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
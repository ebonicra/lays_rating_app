import 'package:flutter/material.dart';

import 'package:lays_rating/models/news_item.dart';
import 'package:lays_rating/widgets/chips/chip_details_page.dart';
import 'package:lays_rating/pages/profile/public_profile_page.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/utils/date_formatter.dart';
import 'package:lays_rating/utils/initials.dart';
import 'package:lays_rating/widgets/common/rating_badge.dart';
import 'package:lays_rating/widgets/common/reaction_button.dart';

/// Содержимое новости «комментарий друга».
class FriendCommentContent extends StatelessWidget {
  const FriendCommentContent({
    super.key,
    required this.item,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.isLiked,
    required this.isDisliked,
    required this.likesCount,
    required this.dislikesCount,
    required this.isReactionLoading,
    required this.onLike,
    required this.onDislike,
  });

  final NewsItem item;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final bool isLiked;
  final bool isDisliked;
  final int likesCount;
  final int dislikesCount;
  final bool isReactionLoading;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  static const int _maxLines = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chip = item.chip;
    final user = item.user;
    final text = item.text ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.record_voice_over_rounded,
              size: 14,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            const Text(
              'Комментарий друга',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (chip != null)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChipDetailsPage(chipId: chip.id),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    '${AuthService.baseUrl}/chips/images/${chip.imagePath}',
                    width: 90,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 90,
                        height: 120,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 30,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, user),
                  const SizedBox(height: 6),
                  _buildText(context, text),
                  const SizedBox(height: 6),
                  if (item.commentId != null)
                    _buildReactionsRow(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user) {
    final theme = Theme.of(context);

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (user != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PublicProfilePage(userId: user.id),
                ),
              );
            }
          },
          child: CircleAvatar(
            radius: 16,
            backgroundImage: user?.avatarUrl != null
                ? NetworkImage(
                    '${AuthService.baseUrl}${user.avatarUrl}',
                  )
                : null,
            child: user?.avatarUrl == null
                ? Text(
                    initialOf(user?.displayName ?? '?'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@${user?.username ?? 'user'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                formatRelativeDate(item.createdAt),
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (item.userRating != null) ...[
          const SizedBox(width: 6),
          RatingBadge(
            rating: item.userRating!,
            iconSize: 14,
            fontSize: 12,
          ),
        ],
      ],
    );
  }

  Widget _buildText(BuildContext context, String text) {
    final theme = Theme.of(context);
    final isLong = _isTextLong(context, text);

    return GestureDetector(
      onTap: isLong ? onToggleExpand : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.3,
                fontSize: 13,
              ),
              maxLines: isExpanded ? null : _maxLines,
              overflow: isExpanded ? null : TextOverflow.ellipsis,
            ),
          ),
          if (isLong)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                isExpanded ? 'Скрыть ▲' : 'Показать полностью ▼',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReactionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ReactionButton(
          icon: Icons.favorite_outline_rounded,
          activeIcon: Icons.favorite_rounded,
          count: likesCount,
          isActive: isLiked,
          activeColor: Colors.red,
          isLoading: isReactionLoading,
          onTap: onLike,
        ),
        const SizedBox(width: 6),
        ReactionButton(
          icon: Icons.heart_broken_outlined,
          activeIcon: Icons.heart_broken_rounded,
          count: dislikesCount,
          isActive: isDisliked,
          activeColor: Colors.brown,
          isLoading: isReactionLoading,
          onTap: onDislike,
        ),
      ],
    );
  }

  bool _isTextLong(BuildContext context, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 13, height: 1.3),
      ),
      maxLines: _maxLines,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 140);
    return textPainter.didExceedMaxLines;
  }
}
import 'package:flutter/material.dart';

import 'package:lays_rating/models/news_item.dart';

import 'admin_post_content.dart';
import 'friend_comment_content.dart';
import 'game_record_content.dart';
import 'new_chip_content.dart';
import 'new_follower_content.dart';
import 'poll_content.dart';
import 'rumor_content.dart';

/// Диспетчер содержимого новости: в зависимости от `eventType`
/// выбирает нужный виджет.
class NewsContent extends StatelessWidget {
  const NewsContent({
    super.key,
    required this.item,
    // friend_comment
    required this.isExpanded,
    required this.onToggleExpand,
    required this.isLiked,
    required this.isDisliked,
    required this.likesCount,
    required this.dislikesCount,
    required this.isReactionLoading,
    required this.onLike,
    required this.onDislike,
    // poll
    required this.onVote,
    required this.onRemoveVote,
  });

  final NewsItem item;

  // === friend_comment ===
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final bool isLiked;
  final bool isDisliked;
  final int likesCount;
  final int dislikesCount;
  final bool isReactionLoading;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  // === poll ===
  final ValueChanged<int> onVote;
  final VoidCallback onRemoveVote;

  @override
  Widget build(BuildContext context) {
    switch (item.eventType) {
      case 'friend_comment':
        return FriendCommentContent(
          item: item,
          isExpanded: isExpanded,
          onToggleExpand: onToggleExpand,
          isLiked: isLiked,
          isDisliked: isDisliked,
          likesCount: likesCount,
          dislikesCount: dislikesCount,
          isReactionLoading: isReactionLoading,
          onLike: onLike,
          onDislike: onDislike,
        );
      case 'new_follower':
        return NewFollowerContent(item: item);
      case 'game_record':
        return GameRecordContent(item: item);
      case 'new_chip':
        return NewChipContent(item: item);
      case 'admin_post':
        return AdminPostContent(item: item);
      case 'rumor':
        return RumorContent(item: item);
      case 'poll':
        return PollContent(
          item: item,
          onVote: onVote,
          onRemoveVote: onRemoveVote,
        );
      default:
        return Text(item.text ?? '');
    }
  }
}
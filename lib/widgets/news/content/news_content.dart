import 'package:flutter/material.dart';

import 'package:lays_rating/models/news_item.dart';

import 'admin_post_content.dart';
import 'friend_comment_content.dart';
import 'game_record_content.dart';
import 'new_chip_content.dart';
import 'new_follower_content.dart';
import 'poll_content.dart';
import 'rumor_content.dart';
import 'news_reactions_bar.dart';

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
    // реакции новости (долгое нажатие)
    this.onShowLikes,
    this.onShowDislikes,
    this.onShowCommentDislikes,
    this.onShowCommentLikes,
  });

  final NewsItem item;

  // === реакции (для friend_comment и для news-реакций) ===
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

  final VoidCallback? onShowLikes;
  final VoidCallback? onShowDislikes;

  final VoidCallback? onShowCommentLikes;
  final VoidCallback? onShowCommentDislikes;

  bool get _isReactableNews {
    final t = item.eventType;
    return t == 'admin_post' || t == 'rumor' || t == 'poll';
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);

    // Для реагируемых новостей добавляем панель реакций снизу.
    if (_isReactableNews) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          content,
          NewsReactionsBar(
            isLiked: isLiked,
            isDisliked: isDisliked,
            likesCount: likesCount,
            dislikesCount: dislikesCount,
            isLoading: isReactionLoading,
            onLike: onLike,
            onDislike: onDislike,
            onShowLikes: onShowLikes,
            onShowDislikes: onShowDislikes,
          ),
        ],
      );
    }

    return content;
  }

  Widget _buildContent(BuildContext context) {
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
          onShowCommentLikes: onShowCommentLikes,
          onShowCommentDislikes: onShowCommentDislikes,
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
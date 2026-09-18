import 'package:flutter/material.dart';

import 'package:lays_rating/models/news_item.dart';
import 'package:lays_rating/models/poll.dart';
import 'package:lays_rating/services/admin_service.dart';
import 'package:lays_rating/services/comments_service.dart';
import 'package:lays_rating/services/news_service.dart';
import 'package:lays_rating/services/user_service.dart';
import 'package:lays_rating/widgets/news/content/news_content.dart';
import 'package:lays_rating/widgets/news/delete_news_dialog.dart';


class NewsCard extends StatefulWidget {
  const NewsCard({
    super.key,
    required this.item,
    this.onDeleted,
    this.onVoted,
  });

  final NewsItem item;
  final VoidCallback? onDeleted;
  final ValueChanged<NewsItem>? onVoted;

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool _isExpanded = false;
  bool _isLiked = false;
  bool _isDisliked = false;
  int _likesCount = 0;
  int _dislikesCount = 0;
  bool _isReactionLoading = false;

  NewsItem get item => widget.item;

  bool get _isAdmin => UserService.currentUser?.isAdmin ?? false;

  bool get _canDelete {
    final type = item.eventType;
    return type == 'admin_post' || type == 'rumor' || type == 'poll';
  }

  @override
  void initState() {
    super.initState();
    _likesCount = item.likesCount ?? 0;
    _dislikesCount = item.dislikesCount ?? 0;

    if (item.myReaction == true) {
      _isLiked = true;
    } else if (item.myReaction == false) {
      _isDisliked = true;
    }
  }

  // ===== РЕАКЦИИ НА КОММЕНТАРИЙ =====

  Future<void> _handleLike() async {
    if (_isReactionLoading) return;
    setState(() => _isReactionLoading = true);

    try {
      if (_isLiked) {
        await CommentsService.removeReaction(commentId: item.commentId!);
        setState(() {
          _isLiked = false;
          _likesCount--;
        });
      } else {
        await CommentsService.setReaction(
          commentId: item.commentId!,
          isLike: true,
        );
        setState(() {
          if (_isDisliked) {
            _isDisliked = false;
            _dislikesCount--;
          }
          _isLiked = true;
          _likesCount++;
        });
      }
    } catch (e) {
      debugPrint('NewsCard._handleLike error: $e');
    }

    if (mounted) setState(() => _isReactionLoading = false);
  }

  Future<void> _handleDislike() async {
    if (_isReactionLoading) return;
    setState(() => _isReactionLoading = true);

    try {
      if (_isDisliked) {
        await CommentsService.removeReaction(commentId: item.commentId!);
        setState(() {
          _isDisliked = false;
          _dislikesCount--;
        });
      } else {
        await CommentsService.setReaction(
          commentId: item.commentId!,
          isLike: false,
        );
        setState(() {
          if (_isLiked) {
            _isLiked = false;
            _likesCount--;
          }
          _isDisliked = true;
          _dislikesCount++;
        });
      }
    } catch (e) {
      debugPrint('NewsCard._handleDislike error: $e');
    }

    if (mounted) setState(() => _isReactionLoading = false);
  }

  // ===== ГОЛОСОВАНИЕ =====

  Future<void> _handleVote(int optionIndex) async {
    try {
      await NewsService.vote(item.id, optionIndex);
      if (!mounted) return;

      final poll = item.poll!;
      final updatedOptions = List<PollOption>.from(poll.options);
      updatedOptions[optionIndex] = updatedOptions[optionIndex].copyWith(
        votes: updatedOptions[optionIndex].votes + 1,
      );

      widget.onVoted?.call(
        item.copyWith(
          poll: poll.copyWith(
            options: updatedOptions,
            totalVotes: poll.totalVotes + 1,
            myVote: optionIndex,
          ),
        ),
      );
    } catch (e) {
      debugPrint('NewsCard._handleVote error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось проголосовать')),
      );
    }
  }

  Future<void> _removeVote() async {
    try {
      await NewsService.removeVote(item.id);
      if (!mounted) return;

      final poll = item.poll!;
      final updatedOptions = List<PollOption>.from(poll.options);

      if (poll.myVote != null) {
        updatedOptions[poll.myVote!] = updatedOptions[poll.myVote!].copyWith(
          votes: updatedOptions[poll.myVote!].votes - 1,
        );
      }

      widget.onVoted?.call(
        item.copyWith(
          poll: poll.copyWith(
            options: updatedOptions,
            totalVotes: poll.totalVotes - 1,
            clearMyVote: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('NewsCard._removeVote error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось отменить голос')),
      );
    }
  }

  // ===== УДАЛЕНИЕ (АДМИН) =====

  Future<void> _deleteNews() async {
    final confirmed = await DeleteNewsDialog.show(context);
    if (confirmed != true || !mounted) return;

    try {
      await AdminService.deleteNews(item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Новость удалена')),
      );
      widget.onDeleted?.call();
    } catch (e) {
      debugPrint('NewsCard._deleteNews error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось удалить новость')),
      );
    }
  }

  // ===== BUILD =====

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          NewsContent(
            item: item,
            isExpanded: _isExpanded,
            onToggleExpand: () => setState(() => _isExpanded = !_isExpanded),
            isLiked: _isLiked,
            isDisliked: _isDisliked,
            likesCount: _likesCount,
            dislikesCount: _dislikesCount,
            isReactionLoading: _isReactionLoading,
            onLike: _handleLike,
            onDislike: _handleDislike,
            onVote: _handleVote,
            onRemoveVote: _removeVote,
          ),
          if (_isAdmin && _canDelete)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: _deleteNews,
                child: Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
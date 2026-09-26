import 'package:flutter/material.dart';

import 'package:lays_rating/models/news_item.dart';
import 'package:lays_rating/models/poll.dart';
import 'package:lays_rating/services/admin_service.dart';
import 'package:lays_rating/services/comments_service.dart';
import 'package:lays_rating/services/news_service.dart';
import 'package:lays_rating/services/user_service.dart';
import 'package:lays_rating/widgets/news/content/news_content.dart';
import 'package:lays_rating/widgets/news/delete_news_dialog.dart';
import 'package:lays_rating/widgets/profile/admin/news/admin_post_page.dart';
import 'package:lays_rating/widgets/profile/admin/news/poll_page.dart';
import 'package:lays_rating/widgets/profile/admin/news/rumor_page.dart';
import 'package:lays_rating/widgets/common/reactions_sheet.dart';
import 'package:lays_rating/utils/reaction_loaders.dart';

class NewsCard extends StatefulWidget {
  const NewsCard({
    super.key,
    required this.item,
    this.onDeleted,
    this.onVoted,
    this.onReacted,
  });

  final NewsItem item;
  final VoidCallback? onDeleted;
  final ValueChanged<NewsItem>? onVoted;

  /// Вызывается после успешной реакции на НОВОСТЬ
  /// (admin_post / rumor / poll), чтобы родитель мог обновить список.
  final ValueChanged<NewsItem>? onReacted;

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool _isExpanded = false;
  bool _isReactionLoading = false;

  // Локальное состояние реакций — чтобы UI отзывался мгновенно.
  bool _isLiked = false;
  bool _isDisliked = false;
  int _likesCount = 0;
  int _dislikesCount = 0;

  NewsItem get item => widget.item;

  bool get _isAdmin => UserService.currentUser?.isAdmin ?? false;

  bool get _canManage {
    final type = item.eventType;
    return type == 'admin_post' || type == 'rumor' || type == 'poll';
  }

  /// Реагируемая ли это НОВОСТЬ (не комментарий).
  bool get _isReactableNews {
    final type = item.eventType;
    return type == 'admin_post' || type == 'rumor' || type == 'poll';
  }

  /// Комментарий ли это (friend_comment).
  bool get _isComment {
    return item.eventType == 'friend_comment';
  }

  void _openReactionsSheet({ReactionsTab? tab}) {
    ReactionsSheet.show(
      context,
      initialTab: tab ?? ReactionsTab.likes,
      loader: () => loadNewsReactions(item.id),
    );
  }

  @override
  void initState() {
    super.initState();
    _syncFromItem();
  }

  @override
  void didUpdateWidget(covariant NewsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Если родитель пересоздал карточку с новыми данными — синхронизируемся.
    if (oldWidget.item != widget.item) {
      _syncFromItem();
    }
  }

  void _syncFromItem() {
    if (_isReactableNews) {
      _likesCount = item.newsLikesCount;
      _dislikesCount = item.newsDislikesCount;
      _isLiked = item.myNewsReaction == true;
      _isDisliked = item.myNewsReaction == false;
    } else if (_isComment) {
      _likesCount = item.commentLikesCount;
      _dislikesCount = item.commentDislikesCount;
      _isLiked = item.myCommentReaction == true;
      _isDisliked = item.myCommentReaction == false;
    } else {
      _likesCount = 0;
      _dislikesCount = 0;
      _isLiked = false;
      _isDisliked = false;
    }
  }

  // ===== РЕАКЦИИ =====

  Future<void> _handleLike() => _handleReaction(isLike: true);

  Future<void> _handleDislike() => _handleReaction(isLike: false);

  Future<void> _handleReaction({required bool isLike}) async {
    if (_isReactionLoading) return;

    // Куда слать — зависит от типа новости.
    if (_isComment) {
      await _handleCommentReaction(isLike: isLike);
    } else if (_isReactableNews) {
      await _handleNewsReaction(isLike: isLike);
    }
    // иначе — реакций нет, ничего не делаем
  }

  /// Реакция на комментарий (через CommentsService).
  Future<void> _handleCommentReaction({required bool isLike}) async {
    final commentId = item.commentId;
    if (commentId == null) return;

    setState(() => _isReactionLoading = true);

    try {
      final wasSameReaction = isLike ? _isLiked : _isDisliked;

      if (wasSameReaction) {
        await CommentsService.removeReaction(commentId: commentId);
        setState(() {
          if (isLike) {
            _isLiked = false;
            _likesCount = (_likesCount - 1).clamp(0, 1 << 31);
          } else {
            _isDisliked = false;
            _dislikesCount = (_dislikesCount - 1).clamp(0, 1 << 31);
          }
        });
      } else {
        await CommentsService.setReaction(
          commentId: commentId,
          isLike: isLike,
        );
        setState(() {
          if (isLike) {
            if (_isDisliked) {
              _isDisliked = false;
              _dislikesCount = (_dislikesCount - 1).clamp(0, 1 << 31);
            }
            _isLiked = true;
            _likesCount++;
          } else {
            if (_isLiked) {
              _isLiked = false;
              _likesCount = (_likesCount - 1).clamp(0, 1 << 31);
            }
            _isDisliked = true;
            _dislikesCount++;
          }
        });
      }
    } catch (e) {
      debugPrint('NewsCard._handleCommentReaction error: $e');
    }

    if (mounted) setState(() => _isReactionLoading = false);
  }



  void _openCommentReactionsSheet(
    int commentId, {
    ReactionsTab? tab,
  }) {
    ReactionsSheet.show(
      context,
      initialTab: tab ?? ReactionsTab.likes,
      loader: () async {
        final data = await CommentsService.getCommentReactions(commentId);
        return ReactionsData(
          likes: data.likes.map((u) => u.toReactionUser()).toList(),
          dislikes: data.dislikes.map((u) => u.toReactionUser()).toList(),
        );
      },
    );
  }

  /// Реакция на новость (через NewsService).
  Future<void> _handleNewsReaction({required bool isLike}) async {
    setState(() => _isReactionLoading = true);

    try {
      final result = await NewsService.setNewsReaction(
        item.id,
        isLike: isLike,
      );

      if (!mounted) return;
      setState(() {
        _likesCount = result.likesCount;
        _dislikesCount = result.dislikesCount;
        _isLiked = result.myReaction == true;
        _isDisliked = result.myReaction == false;
      });

      // Прокидываем обновлённый item наверх, чтобы родитель обновил список.
      widget.onReacted?.call(
        item.copyWith(
          newsLikesCount: result.likesCount,
          newsDislikesCount: result.dislikesCount,
          myNewsReaction: result.myReaction,
          clearNewsReaction: result.myReaction == null,
        ),
      );
    } catch (e) {
      debugPrint('NewsCard._handleNewsReaction error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось сохранить реакцию'),
        ),
      );
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
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось проголосовать'),
        ),
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
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось отменить голос'),
        ),
      );
    }
  }

  // ===== УДАЛЕНИЕ / РЕДАКТИРОВАНИЕ (АДМИН) =====

  Future<void> _deleteNews() async {
    final confirmed = await DeleteNewsDialog.show(context);
    if (confirmed != true || !mounted) return;

    try {
      await AdminService.deleteNews(item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Новость удалена'),
        ),
      );
      widget.onDeleted?.call();
    } catch (e) {
      debugPrint('NewsCard._deleteNews error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось удалить новость'),
        ),
      );
    }
  }

  Future<void> _openEditNews() async {
    final Widget page;
    switch (item.eventType) {
      case 'admin_post':
        page = AdminPostPage(initialNews: item);
        break;
      case 'rumor':
        page = RumorPage(initialNews: item);
        break;
      case 'poll':
        page = PollPage(initialNews: item);
        break;
      default:
        return;
    }

    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );

    if (updated == true && mounted) {
      widget.onDeleted?.call();
    }
  }

  // ===== BUILD =====

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
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
            onShowLikes: () => _openReactionsSheet(tab: ReactionsTab.likes),
            onShowDislikes: () => _openReactionsSheet(tab: ReactionsTab.dislikes),
            onShowCommentLikes: () {
              final commentId = item.commentId;
              if (commentId == null) return;
              _openCommentReactionsSheet(commentId, tab: ReactionsTab.likes);
            },
            onShowCommentDislikes: () {
              final commentId = item.commentId;
              if (commentId == null) return;
              _openCommentReactionsSheet(commentId, tab: ReactionsTab.dislikes);
            },
          ),
          if (_isAdmin && _canManage)
            Positioned(
              top: 0,
              right: 0,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _openEditNews,
                    child: Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _deleteNews,
                    child: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
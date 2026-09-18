import 'package:flutter/material.dart';

import 'package:lays_rating/models/chip_comment.dart';
import 'package:lays_rating/pages/profile/public_profile_page.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/services/comments_service.dart';
import 'package:lays_rating/services/user_service.dart';
import 'package:lays_rating/utils/initials.dart';
import 'package:lays_rating/widgets/common/rating_badge.dart';
import 'package:lays_rating/widgets/common/reaction_button.dart';

import 'delete_comment_dialog.dart';
import 'edit_comment_dialog.dart';


class CommentCard extends StatefulWidget {
  const CommentCard({
    super.key,
    required this.comment,
    required this.chipId,
  });

  final ChipCommentResponse comment;
  final int chipId;

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  static const int _maxLinesCollapsed = 3;

  late ChipCommentResponse _comment;
  bool _isLoading = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _comment = widget.comment;
  }

  @override
  void didUpdateWidget(CommentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.comment.id != widget.comment.id) {
      _comment = widget.comment;
    }
  }

  bool get _isMyComment =>
      UserService.currentUser?.id == _comment.user.id;

  // ===== РЕАКЦИИ =====

  Future<void> _handleLike() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      if (_comment.userReaction?.isLiked == true) {
        await CommentsService.removeReaction(commentId: _comment.id);
        _comment = _comment.copyWith(
          likesCount: _comment.likesCount - 1,
          userReaction: const CommentReactionResponse(isLiked: null),
        );
      } else {
        await CommentsService.setReaction(
          commentId: _comment.id,
          isLike: true,
        );
        _comment = _comment.copyWith(
          likesCount: _comment.likesCount + 1,
          dislikesCount: _comment.userReaction?.isLiked == false
              ? _comment.dislikesCount - 1
              : _comment.dislikesCount,
          userReaction: const CommentReactionResponse(isLiked: true),
        );
      }
    } catch (e) {
      debugPrint('CommentCard._handleLike error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось поставить реакцию')),
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleDislike() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      if (_comment.userReaction?.isLiked == false) {
        await CommentsService.removeReaction(commentId: _comment.id);
        _comment = _comment.copyWith(
          dislikesCount: _comment.dislikesCount - 1,
          userReaction: const CommentReactionResponse(isLiked: null),
        );
      } else {
        await CommentsService.setReaction(
          commentId: _comment.id,
          isLike: false,
        );
        _comment = _comment.copyWith(
          dislikesCount: _comment.dislikesCount + 1,
          likesCount: _comment.userReaction?.isLiked == true
              ? _comment.likesCount - 1
              : _comment.likesCount,
          userReaction: const CommentReactionResponse(isLiked: false),
        );
      }
    } catch (e) {
      debugPrint('CommentCard._handleDislike error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось поставить реакцию')),
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // ===== ДЕЙСТВИЯ =====

  Future<void> _openEditDialog() async {
    final updated = await EditCommentDialog.show(context, _comment);
    if (updated == null || !mounted) return;
    setState(() => _comment = updated);
  }

  Future<void> _openDeleteDialog() async {
    final confirmed = await DeleteCommentDialog.show(context);
    if (confirmed != true || !mounted) return;

    try {
      await CommentsService.deleteComment(commentId: _comment.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Комментарий удалён')),
      );
      // TODO: сообщить родителю, чтобы убрал карточку из списка
    } catch (e) {
      debugPrint('CommentCard._openDeleteDialog error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось удалить')),
      );
    }
  }

  // ===== BUILD =====

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLongText = _isTextLong(_comment.text);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          const SizedBox(height: 6),
          _buildText(theme, isLongText),
          const SizedBox(height: 12),
          _buildActionsRow(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PublicProfilePage(userId: _comment.user.id),
              ),
            );
          },
          child: CircleAvatar(
            radius: 18,
            backgroundColor: theme.colorScheme.primaryContainer,
            backgroundImage: _comment.user.avatarUrl != null
                ? NetworkImage(
                    '${AuthService.baseUrl}${_comment.user.avatarUrl}',
                  )
                : null,
            child: _comment.user.avatarUrl == null
                ? Text(
                    initialOf(_comment.user.username),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _comment.user.username,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  height: 1.2,
                ),
              ),
              Text(
                _formatDate(_comment.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        if (_comment.rating != null)
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: RatingBadge(rating: _comment.rating!),
          ),
      ],
    );
  }

  Widget _buildText(ThemeData theme, bool isLongText) {
    if (!isLongText) {
      return Text(
        _comment.text,
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _comment.text,
            maxLines: _isExpanded ? null : _maxLinesCollapsed,
            overflow: _isExpanded ? null : TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
          const SizedBox(height: 4),
          Text(
            _isExpanded ? 'Скрыть ▲' : 'Показать полностью ▼',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsRow(ThemeData theme) {
    return Row(
      children: [
        ReactionButton(
          icon: Icons.favorite_outline_rounded,
          activeIcon: Icons.favorite_rounded,
          count: _comment.likesCount,
          isActive: _comment.userReaction?.isLiked == true,
          activeColor: Colors.red,
          isLoading: _isLoading,
          onTap: _handleLike,
        ),
        const SizedBox(width: 6),
        ReactionButton(
          icon: Icons.heart_broken_outlined,
          activeIcon: Icons.heart_broken_rounded,
          count: _comment.dislikesCount,
          isActive: _comment.userReaction?.isLiked == false,
          activeColor: Colors.brown,
          isLoading: _isLoading,
          onTap: _handleDislike,
        ),
        const Spacer(),
        if (_isMyComment) ...[
          _MiniCircleButton(
            icon: Icons.edit_outlined,
            onTap: _openEditDialog,
          ),
          const SizedBox(width: 1),
          _MiniCircleButton(
            icon: Icons.delete_outline,
            onTap: _openDeleteDialog,
          ),
          const SizedBox(width: 2),
        ],
      ],
    );
  }

  // ===== ХЕЛПЕРЫ =====

  bool _isTextLong(String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
      ),
      maxLines: _maxLinesCollapsed,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 80);
    return textPainter.didExceedMaxLines;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'только что';
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин. назад';
    if (diff.inHours < 24) return '${diff.inHours} ч. назад';
    if (diff.inDays < 7) return '${diff.inDays} д. назад';
    return '${date.day}.${date.month}.${date.year}';
  }
}

// ===== ПРИВАТНЫЕ ВИДЖЕТЫ =====


class _MiniCircleButton extends StatelessWidget {
  const _MiniCircleButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(
          icon,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
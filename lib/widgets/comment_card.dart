import 'package:flutter/material.dart';
import 'package:lays_rating/models/chip_comment.dart';
import '../services/comments_server.dart';
import '../services/auth_service.dart';
import 'package:lays_rating/services/user_service.dart';
import '../pages/public_profile_page.dart';


class CommentCard extends StatefulWidget {
  final ChipCommentResponse comment;
  final int chipId;

  const CommentCard({
    super.key,
    required this.comment,
    required this.chipId,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  late ChipCommentResponse _comment;
  bool _isLoading = false;
  bool _isExpanded = false;
  static const int _maxLinesCollapsed = 3;

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


  // Обработка лайка
  Future<void> _handleLike() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      if (_comment.userReaction?.isLiked == true) {
        // Уже лайкнуто — убираем реакцию
        await CommentsService.removeReaction(
          chipId: widget.chipId,
          commentId: _comment.id,
        );
        _comment = _comment.copyWith(
          likesCount: _comment.likesCount - 1,
          userReaction: const CommentReactionResponse(isLiked: null),
        );
      } else {
        // Ставим лайк (или меняем дизлайк на лайк)
        await CommentsService.setReaction(
          chipId: widget.chipId,
          commentId: _comment.id,
          isLike: true,
        );
        _comment = _comment.copyWith(
          likesCount: _comment.userReaction?.isLiked == false
              ? _comment.likesCount + 1
              : _comment.likesCount + 1,
          dislikesCount: _comment.userReaction?.isLiked == false
              ? _comment.dislikesCount - 1
              : _comment.dislikesCount,
          userReaction: const CommentReactionResponse(isLiked: true),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось поставить реакцию')),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }


  // Обработка дизлайка
  Future<void> _handleDislike() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      if (_comment.userReaction?.isLiked == false) {
        // Уже дизлайкнуто — убираем реакцию
        await CommentsService.removeReaction(
          chipId: widget.chipId,
          commentId: _comment.id,
        );
        _comment = _comment.copyWith(
          dislikesCount: _comment.dislikesCount - 1,
          userReaction: const CommentReactionResponse(isLiked: null),
        );
      } else {
        // Ставим дизлайк (или меняем лайк на дизлайк)
        await CommentsService.setReaction(
          chipId: widget.chipId,
          commentId: _comment.id,
          isLike: false,
        );
        _comment = _comment.copyWith(
          dislikesCount: _comment.userReaction?.isLiked == true
              ? _comment.dislikesCount + 1
              : _comment.dislikesCount + 1,
          likesCount: _comment.userReaction?.isLiked == true
              ? _comment.likesCount - 1
              : _comment.likesCount,
          userReaction: const CommentReactionResponse(isLiked: false),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось поставить реакцию')),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }


  // Показать диалог редактирования
  void _showEditDialog() {
    final controller = TextEditingController(text: _comment.text);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Заголовок
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Редактировать',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Поле ввода
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 4,
                minLines: 2,
                decoration: InputDecoration(
                  hintText: 'Исправь своё мнение...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Кнопка сохранить
              ElevatedButton(
                onPressed: () async {
                  if (controller.text.trim().isNotEmpty) {
                    try {
                      final updated = await CommentsService.updateComment(
                        chipId: widget.chipId,
                        commentId: _comment.id,
                        text: controller.text.trim(),
                      );
                      setState(() => _comment = updated);
                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Не удалось обновить')),
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Сохранить'),
              ),
            ],
          ),
        );
      },
    );
  }
  
  
  // Показать диалог удаления
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить комментарий?'),
        content: const Text('Это действие нельзя отменить'),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    try {
                      await CommentsService.deleteComment(
                        chipId: widget.chipId,
                        commentId: _comment.id,
                      );
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Комментарий удалён')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Не удалось удалить')),
                      );
                    }
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Удалить'),
                ),
              ),
            ],
          ),
        ],

        // actions: [
        //   TextButton(
        //     onPressed: () => Navigator.pop(context),
        //     child: const Text('Отмена'),
        //   ),
        //   TextButton(
        //     onPressed: () async {
        //       try {
        //         await CommentsService.deleteComment(
        //           chipId: widget.chipId,
        //           commentId: _comment.id,
        //         );
        //         if (mounted) {
        //           Navigator.pop(context);
        //           ScaffoldMessenger.of(context).showSnackBar(
        //             const SnackBar(content: Text('Комментарий удалён')),
        //           );
        //         }
        //       } catch (e) {
        //         ScaffoldMessenger.of(context).showSnackBar(
        //           const SnackBar(content: Text('Не удалось удалить')),
        //         );
        //       }
        //     },
        //     style: TextButton.styleFrom(foregroundColor: Colors.red),
        //     child: const Text('Удалить'),
        //   ),
        // ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final comment = widget.comment;
    final isLongText = _isTextLong(_comment.text);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Автор, дата и оценка
          Row(
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
                      ? NetworkImage('${AuthService.baseUrl}${_comment.user.avatarUrl}')
                      : null,
                  child: _comment.user.avatarUrl == null
                      ? Text(
                          _comment.user.username[0].toUpperCase(),
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
                      ),
                    ),
                    Text(
                      _formatDate(_comment.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (_comment.rating != null) 
                Padding(
                  padding: const EdgeInsets.only(right: 2), // ← как у кнопок
                  child: _RatingBadge(rating: _comment.rating!),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Текст с разворачиванием
          if (isLongText)
            GestureDetector(
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
            )
          else
            Text(
              _comment.text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          const SizedBox(height: 12),

          // Лайки / Дизлайки
          Row(
            children: [
              _ReactionButton(
                icon: Icons.thumb_up_outlined,
                activeIcon: Icons.thumb_up,
                count: _comment.likesCount,
                isActive: _comment.userReaction?.isLiked == true,
                activeColor: Colors.blue,
                isLoading: _isLoading,
                onTap: _handleLike,
              ),
              const SizedBox(width: 6),
              _ReactionButton(
                icon: Icons.thumb_down_outlined,
                activeIcon: Icons.thumb_down,
                count: _comment.dislikesCount,
                isActive: _comment.userReaction?.isLiked == false,
                activeColor: Colors.red,
                isLoading: _isLoading,
                onTap: _handleDislike,
              ),

              const Spacer(),
              if (_isMyComment) ...[
                _MiniCircleButton(
                  icon: Icons.edit_outlined,
                  onTap: _showEditDialog,
                ),
                const SizedBox(width: 6),
                _MiniCircleButton(
                  icon: Icons.delete_outline,
                  onTap: _showDeleteDialog,
                ),
                const SizedBox(width: 8),
              ],


            ],
          ),
        ],
      ),
    );
  }

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


  bool get _isMyComment {
    return UserService.currentUser?.id == _comment.user.id;

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

/// Плашка с оценкой
class _RatingBadge extends StatelessWidget {
  final int rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: _getRatingColors(rating),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _getRatingColors(rating)[0].withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 4),
          Text(
            '$rating',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getRatingColors(int rating) {
    if (rating >= 5) return [Color(0xFF00E676), Color(0xFF1B5E20)];
    if (rating >= 4) return [Color(0xFFAED581),  Color(0xFF00E676)];
    if (rating >= 3) return [Color(0xFFFFC107), Color(0xFFFF9800)];
    if (rating >= 2) return [Color(0xFFE65100), Color(0xFFFF9800)];
    return [Color(0xFFD32F2F), Color(0xFFB71C1C)];
  }
}

/// Кнопка лайка/дизлайка
class _ReactionButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final int count;
  final bool isActive;
  final Color activeColor;
  final bool isLoading;
  final VoidCallback onTap;

  const _ReactionButton({
    required this.icon,
    required this.activeIcon,
    required this.count,
    required this.isActive,
    required this.activeColor,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 18,
              color: isActive ? activeColor : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? activeColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



/// Мини-кнопка на круглой серой подложке
class _MiniCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniCircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 25,
        height: 25,
        // padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 15,
          color:Colors.grey.shade600,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lays_rating/models/chip_comment.dart';
import 'package:lays_rating/services/comments_server.dart';

import 'package:lays_rating/widgets/comments_page.dart';
import 'package:lays_rating/widgets/comment_card.dart';

class CommentsSection extends StatefulWidget {
  final int chipId;

  const CommentsSection({
    super.key,
    required this.chipId,
  });

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  List<ChipCommentResponse>? _comments;
  bool _isLoading = true;
  String? _error;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await CommentsService.getComments(
        chipId: widget.chipId,
        page: 1,
        perPage: 5,        // ← только 5
        sortBy: 'newest', // ← самые лучшие (по рейтингу)
      );

      if (mounted) {
        setState(() {
          _comments = response.comments;
          _totalCount = response.totalCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Не удалось загрузить комментарии';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToAllComments() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommentsPage(chipId: widget.chipId),
      ),
    );
    _loadComments();
  }

  Future<void> _createComment(String text) async {
    try {
      final newComment = await CommentsService.createComment(
        chipId: widget.chipId,
        text: text,
      );
      
      if (mounted) {
        setState(() {
          _comments = [newComment, ...?_comments];
          _totalCount++;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось добавить комментарий')),
        );
      }
    }
  }

  void _showCreateCommentDialog() {
    final controller = TextEditingController();
    
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Новое важное мнение🧐',
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
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 4,
                minLines: 2,
                decoration: InputDecoration(
                  hintText: 'Ну давай, расскажи, какая это хуета...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    _createComment(controller.text.trim());
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Отправить'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Комментарии ($_totalCount)',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Написать
                IconButton(
                  onPressed: _showCreateCommentDialog,
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 23, color: Color.fromARGB(255, 141, 8, 75)),
                  tooltip: 'Написать',
                ),
                const SizedBox(width: 4),
                // Развернуть — показать все
                IconButton(
                  onPressed: _navigateToAllComments,
                  icon: const Icon(Icons.format_list_bulleted_rounded, size: 25, color: Color.fromARGB(255, 141, 8, 75)),
                  tooltip: 'Все комментарии',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Контент
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_error != null)
          _buildErrorState(theme)
        else if (_comments == null || _comments!.isEmpty)
          _buildEmptyState(theme)
        else
          _buildCommentsList(theme),
      ],
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadComments,
              child: const Text('Попробовать снова'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Пока нет комментариев',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Будь первым, кто поделится мнением!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList(ThemeData theme) {
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _comments!.length > 5 ? 5 : _comments!.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return CommentCard(
              comment: _comments![index],
              chipId: widget.chipId,
            );
          },
        ),

        // Кнопка "Все комментарии"
        if (_totalCount > 0) ...[
          const SizedBox(height: 2),
          Center(
            child: TextButton.icon(
              onPressed: _navigateToAllComments, // ← обновлённый метод
              icon: const Icon(Icons.arrow_forward),
              label: Text('Все комментарии ($_totalCount)'),
            ),
          ),
        ],
      ],
    );
  }
}




/// Кнопка лайка/дизлайка
class _ReactionButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final int count;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _ReactionButton({
    required this.icon,
    required this.activeIcon,
    required this.count,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
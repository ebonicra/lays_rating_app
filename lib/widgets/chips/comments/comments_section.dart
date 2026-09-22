import 'package:flutter/material.dart';

import 'package:lays_rating/models/chip_comment.dart';
import 'package:lays_rating/pages/chips/comments_page.dart';
import 'package:lays_rating/services/comments_service.dart';
import 'package:lays_rating/widgets/chips/comments/comment_card.dart';
import 'package:lays_rating/widgets/chips/comments/create_comment_dialog.dart';


class CommentsSection extends StatefulWidget {
  const CommentsSection({
    super.key,
    required this.chipId,
  });

  final int chipId;

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
        perPage: 5,
        sortBy: 'newest',
      );

      if (!mounted) return;
      setState(() {
        _comments = response.comments;
        _totalCount = response.totalCount;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('CommentsSection._loadComments error: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Не удалось загрузить комментарии';
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToAllComments() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommentsPage(chipId: widget.chipId),
      ),
    );
    if (mounted) _loadComments();
  }

  Future<void> _openCreateCommentDialog() async {
    final text = await CreateCommentDialog.show(context);
    if (text == null || !mounted) return;
    await _createComment(text);
  }

  Future<void> _createComment(String text) async {
    try {
      final newComment = await CommentsService.createComment(
        chipId: widget.chipId,
        text: text,
      );

      if (!mounted) return;
      setState(() {
        _comments = [newComment, ...?_comments];
        _totalCount++;
      });
    } catch (e) {
      debugPrint('CommentsSection._createComment error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось добавить комментарий')
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            IconButton(
              onPressed: _openCreateCommentDialog,
              icon: Icon(
                Icons.edit_note_rounded,
                size: 30,
                color: theme.colorScheme.primary,
              ),
              tooltip: 'Написать',
            ),
          ],
        ),
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

  Widget _buildOutlinedBox(ThemeData theme, Widget child) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Center(child: child),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return _buildOutlinedBox(
      theme,
      Column(
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
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return _buildOutlinedBox(
      theme,
      Column(
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
    );
  }

  Widget _buildCommentsList(ThemeData theme) {
    final comments = _comments!;
    final visible = comments.length > 5 ? comments.sublist(0, 5) : comments;

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visible.length,
          separatorBuilder: (_, __) => Divider(
            height: 10,
            thickness: 1,
            color: theme.colorScheme.outlineVariant.withOpacity(0.2),
          ),
          itemBuilder: (context, index) {
            return CommentCard(
              comment: visible[index],
              chipId: widget.chipId,
            );
          },
        ),
        const SizedBox(height: 8),
        if (_totalCount > 0)
          Center(
            child: TextButton.icon(
              onPressed: _navigateToAllComments,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: Text(
                'Все комментарии ($_totalCount)',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
      ],
    );
  }
}
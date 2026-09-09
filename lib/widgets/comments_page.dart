import 'package:flutter/material.dart';
import 'package:lays_rating/models/chip_comment.dart';
import 'package:lays_rating/services/comments_server.dart';
import 'package:lays_rating/widgets/comment_card.dart';

class CommentsPage extends StatefulWidget {
  final int chipId;

  const CommentsPage({
    super.key,
    required this.chipId,
  });

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  List<ChipCommentResponse> _comments = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _totalCount = 0;
  int _currentPage = 1;
  String _sortBy = 'newest'; // newest, oldest, popular
  final int _perPage = 20;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadComments();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _comments.length < _totalCount) {
      _loadMore();
    }
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
    });

    try {
      final response = await CommentsService.getComments(
        chipId: widget.chipId,
        page: _currentPage,
        perPage: _perPage,
        sortBy: _sortBy,
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

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);

    try {
      final response = await CommentsService.getComments(
        chipId: widget.chipId,
        page: _currentPage + 1,
        perPage: _perPage,
        sortBy: _sortBy,
      );

      if (mounted) {
        setState(() {
          _comments.addAll(response.comments);
          _currentPage++;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  Future<void> _createComment(String text) async {
    try {
      final newComment = await CommentsService.createComment(
        chipId: widget.chipId,
        text: text,
      );

      if (mounted) {
        setState(() {
          _comments.insert(0, newComment);
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
                    'Новый комментарий',
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
                  hintText: 'Поделись своим мнением о чипсах...',
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Комментарии'),
        actions: [
          IconButton(
            onPressed: _showCreateCommentDialog,
            icon: const Icon(Icons.add_comment_rounded),
            tooltip: 'Написать',
          ),
        ],
      ),
      body: Column(
        children: [
          // Сортировка
          _buildSortBar(theme),
          const Divider(height: 1),

          // Список
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState(theme)
                    : _comments.isEmpty
                        ? _buildEmptyState(theme)
                        : _buildCommentsList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Text(
          //   '$_totalCount комментариев',
          //   style: TextStyle(
          //     color: theme.colorScheme.onSurfaceVariant,
          //     fontSize: 14,
          //   ),
          // ),
          // const Spacer(),
          _SortChip(
            label: 'Новые',
            isActive: _sortBy == 'newest',
            onTap: () {
              setState(() => _sortBy = 'newest');
              _loadComments();
            },
          ),
          const SizedBox(width: 8),
          _SortChip(
            label: 'Старые',
            isActive: _sortBy == 'oldest',
            onTap: () {
              setState(() => _sortBy = 'oldest');
              _loadComments();
            },
          ),
          const SizedBox(width: 8),
          _SortChip(
            label: 'Лучшие',
            isActive: _sortBy == 'popular',
            onTap: () {
              setState(() => _sortBy = 'popular');
              _loadComments();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _loadComments,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _comments.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, index) {
          // Не показываем разделитель после последнего комментария
          if (index == _comments.length - 1) return const SizedBox.shrink();
          return Divider(
            height: 10,
            thickness: 1,
            color: theme.colorScheme.outlineVariant.withOpacity(0.2),
          );
        },
        itemBuilder: (context, index) {
          if (index == _comments.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return CommentCard(
            comment: _comments[index],
            chipId: widget.chipId,
          );
        },
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
}

/// Чип для сортировки
class _SortChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
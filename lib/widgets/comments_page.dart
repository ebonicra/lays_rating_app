import 'package:flutter/material.dart';
import 'package:lays_rating/models/chip_comment.dart';
import 'package:lays_rating/services/comments_service.dart';
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
            left: 15,
            right: 15,
            top: 5,
            bottom: MediaQuery.of(context).viewInsets.bottom + 15,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Заголовок
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4), // ← сдвиг текста
                    child: const Text(
                      'Новый комментарий',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              // Поле с самолётиком через Stack
              Stack(
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    maxLines: 6,
                    minLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Поделись своим мнением о чипсах...',
                      hintStyle: const TextStyle(fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(12, 12, 50, 12),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () {
                        if (controller.text.trim().isNotEmpty) {
                          _createComment(controller.text.trim());
                          Navigator.pop(context);
                        }
                      },
                      icon: Icon(
                        Icons.send_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      tooltip: 'Отправить',
                    ),
                  ),
                ],
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
          Transform.translate(
            offset: const Offset(8, 0), // ← сдвигаем влево
            child: IconButton(
              onPressed: _showCreateCommentDialog,
              icon: const Icon(Icons.edit_note_rounded),
              tooltip: 'Написать',
              iconSize: 28,
              padding: EdgeInsets.zero,
              visualDensity: const VisualDensity(horizontal: -4.0, vertical: -2.0),
            )
          ),
          Transform.translate(
            offset: const Offset(4, 0), // ← сдвигаем влево
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.swap_vert_rounded),
              iconSize: 26,
              tooltip: 'Сортировка',
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value != _sortBy) {
                  setState(() => _sortBy = value);
                  _loadComments();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'newest',
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: 140, // ← фиксированная ширина
                    child: Row(
                      children: [
                        Text(
                          'Сначала новые',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _sortBy == 'newest' ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (_sortBy == 'newest') ...[
                          const Spacer(),
                          Icon(
                            Icons.check,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'oldest',
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: 140,
                    child: Row(
                      children: [
                        Text(
                          'Сначала старые',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _sortBy == 'oldest' ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (_sortBy == 'oldest') ...[
                          const Spacer(),
                          Icon(
                            Icons.check,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'popular',
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: 140,
                    child: Row(
                      children: [
                        Text(
                          'Сначала лучшие',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _sortBy == 'popular' ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (_sortBy == 'popular') ...[
                          const Spacer(),
                          Icon(
                            Icons.check,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? _buildErrorState(theme)
            : _comments.isEmpty
                ? _buildEmptyState(theme)
                : _buildCommentsList(theme),
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





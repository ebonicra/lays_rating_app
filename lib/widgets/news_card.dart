import 'package:flutter/material.dart';
import 'package:lays_rating/models/news_item.dart';
import 'package:lays_rating/models/poll.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/services/admin_service.dart';
import 'package:lays_rating/services/news_service.dart';
import 'package:lays_rating/services/user_service.dart';
import 'package:lays_rating/pages/public_profile_page.dart';
import 'package:lays_rating/pages/chips/chip_details_page.dart';
import 'package:lays_rating/widgets/rating_badge.dart';
import 'package:lays_rating/services/comments_server.dart';

class NewsCard extends StatefulWidget {
  final NewsItem item;
  final VoidCallback? onDeleted;
  final ValueChanged<NewsItem>? onVoted;

  const NewsCard({
    super.key,
    required this.item,
    this.onDeleted,
    this.onVoted,
  });

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
  static const int _maxLines = 4;

  NewsItem get item => widget.item;

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

  bool get _isAdmin {
    return UserService.currentUser?.isAdmin ?? false;
  }

  Future<void> _handleLike() async {
    if (_isReactionLoading) return;
    setState(() => _isReactionLoading = true);

    try {
      if (_isLiked) {
        await CommentsService.removeReaction(
          chipId: item.chip!.id,
          commentId: item.commentId!,
        );
        setState(() {
          _isLiked = false;
          _likesCount--;
        });
      } else {
        await CommentsService.setReaction(
          chipId: item.chip!.id,
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
      // ошибка
    }

    if (mounted) setState(() => _isReactionLoading = false);
  }

  Future<void> _handleDislike() async {
    if (_isReactionLoading) return;
    setState(() => _isReactionLoading = true);

    try {
      if (_isDisliked) {
        await CommentsService.removeReaction(
          chipId: item.chip!.id,
          commentId: item.commentId!,
        );
        setState(() {
          _isDisliked = false;
          _dislikesCount--;
        });
      } else {
        await CommentsService.setReaction(
          chipId: item.chip!.id,
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
      // ошибка
    }

    if (mounted) setState(() => _isReactionLoading = false);
  }

  Future<void> _handleVote(int optionIndex) async {
    try {
      await NewsService.vote(item.id, optionIndex);

      if (mounted) {
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          _buildContent(context),

          if (_isAdmin &&
              (item.eventType == 'admin_post' ||
                  item.eventType == 'rumor' ||
                  item.eventType == 'poll'))
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: _deleteNews,
                child: Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _deleteNews() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить новость?'),
        content: const Text('Это действие нельзя отменить'),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Отмена'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Удалить'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await AdminService.deleteNews(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Новость удалена')),
        );
        widget.onDeleted?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка: $e')),
        );
      }
    }
  }

  Widget _buildContent(BuildContext context) {
    switch (item.eventType) {
      case 'friend_comment':
        return _buildFriendComment(context);
      case 'new_follower':
        return _buildNewFollower(context);
      case 'game_record':
        return _buildGameRecord(context);
      case 'new_chip':
        return _buildNewChip(context);
      case 'admin_post':
        return _buildAdminPost(context);
      case 'rumor':
        return _buildRumor(context);
      case 'poll':
        return _buildPoll(context);
      default:
        return Text(item.text ?? '');
    }
  }

  Widget _buildFriendComment(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.record_voice_over_rounded,
              size: 14,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            const Text(
              'Комментарий друга',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.chip != null)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChipDetailsPage(chipId: item.chip!.id),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    '${AuthService.baseUrl}/chips/images/${item.chip!.imagePath}',
                    width: 90,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 90,
                        height: 120,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey, size: 30),
                        ),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (item.user != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PublicProfilePage(userId: item.user!.id),
                              ),
                            );
                          }
                        },
                        child: CircleAvatar(
                          radius: 16,
                          backgroundImage: item.user?.avatarUrl != null
                              ? NetworkImage('${AuthService.baseUrl}${item.user!.avatarUrl}')
                              : null,
                          child: item.user?.avatarUrl == null
                              ? Text(
                                  item.user?.displayName.substring(0, 1).toUpperCase() ?? '?',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '@${item.user?.username ?? 'user'}',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _formatDate(item.createdAt),
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      if (item.userRating != null) ...[
                        const SizedBox(width: 6),
                        RatingBadge(rating: item.userRating!, iconSize: 14, fontSize: 12),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _isTextLong(item.text ?? '')
                        ? () => setState(() => _isExpanded = !_isExpanded)
                        : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 52),
                          child: Text(
                            item.text ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(height: 1.3, fontSize: 13),
                            maxLines: _isExpanded ? null : _maxLines,
                            overflow: _isExpanded ? null : TextOverflow.ellipsis,
                          ),
                        ),
                        if (_isTextLong(item.text ?? ''))
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              _isExpanded ? 'Скрыть ▲' : 'Показать полностью ▼',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (item.commentId != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _ReactionButton(
                          icon: Icons.favorite_outline_rounded,
                          activeIcon: Icons.favorite_rounded,
                          count: _likesCount,
                          isActive: _isLiked,
                          activeColor: Colors.red,
                          isLoading: _isReactionLoading,
                          onTap: _handleLike,
                        ),
                        const SizedBox(width: 6),
                        _ReactionButton(
                          icon: Icons.heart_broken_outlined,
                          activeIcon: Icons.heart_broken_rounded,
                          count: _dislikesCount,
                          isActive: _isDisliked,
                          activeColor: Colors.brown,
                          isLoading: _isReactionLoading,
                          onTap: _handleDislike,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNewFollower(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person_add_rounded, size: 14, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            const Text(
              'У вас новый подписчик!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: item.user?.avatarUrl != null
                  ? NetworkImage('${AuthService.baseUrl}${item.user!.avatarUrl}')
                  : null,
              child: item.user?.avatarUrl == null
                  ? Text(
                      item.user?.displayName.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '@${item.user?.username ?? 'user'}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(item.createdAt),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _isTextLong(String text) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(fontSize: 13, height: 1.3)),
      maxLines: _maxLines,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 140);
    return textPainter.didExceedMaxLines;
  }

  Widget _buildGameRecord(BuildContext context) {
    final score = item.extraData?['score'] ?? 0;
    return Row(
      children: [
        const Icon(Icons.sports_esports, size: 32, color: Colors.purple),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '${item.user?.displayName ?? 'Кто-то'} набрал $score очков в игре! 🎮',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildNewChip(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome_rounded, size: 14, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            const Text(
              'Появился новый вкус!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (item.chip != null)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChipDetailsPage(chipId: item.chip!.id)),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                '${AuthService.baseUrl}/chips/images/${item.chip!.imagePath}',
                width: double.infinity,
                height: 230,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                    ),
                  );
                },
              ),
            ),
          ),
        const SizedBox(height: 8),
        if (item.chip != null)
          Center(
            child: Text(
              item.chip!.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 2),
        Center(
          child: Text(
            'Оцените новый вкус! 😋',
            style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildRumor(BuildContext context) {
    final theme = Theme.of(context);
    final chips = item.extraData?['chips'] as List<dynamic>? ?? [];
    final source = item.extraData?['source'] as String? ?? '';
    final imageSize = chips.length == 1
        ? 180.0
        : chips.length == 2
            ? 140.0
            : chips.length == 3
                ? 110.0
                : 85.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.psychology_rounded, size: 14, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            const Text(
              'Ходят слухи...',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (chips.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: chips.asMap().entries.map((entry) {
              final index = entry.key;
              final chip = entry.value;
              final imagePath = chip['image_path'];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _FullScreenImageViewer(
                        chips: chips,
                        initialIndex: index,
                      ),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      '${AuthService.baseUrl}/news/images/$imagePath',
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: imageSize,
                          height: imageSize,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, color: Colors.grey, size: 32),
                        );
                      },
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 12),
        if (item.text != null && item.text!.isNotEmpty) ...[
          Center(
            child: Text(
              item.text!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.3, fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (source.isNotEmpty)
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                source,
                style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildAdminPost(BuildContext context) {
    final theme = Theme.of(context);
    final chips = item.extraData?['chips'] as List<dynamic>? ?? [];
    final imageSize = chips.length == 1
        ? 180.0
        : chips.length == 2
            ? 140.0
            : chips.length == 3
                ? 90.0
                : 70.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.campaign_rounded, size: 14, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            const Text(
              'От админа',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (chips.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: chips.asMap().entries.map((entry) {
              final index = entry.key;
              final chip = entry.value;
              final imagePath = chip['image_path'];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _FullScreenImageViewer(
                        chips: chips,
                        initialIndex: index,
                      ),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      '${AuthService.baseUrl}/news/images/$imagePath',
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: imageSize,
                          height: imageSize,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        if (item.text != null && item.text!.isNotEmpty)
          Center(
            child: Text(
              item.text!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.3, fontSize: 16),
            ),
          ),
      ],
    );
  }

  Widget _buildPoll(BuildContext context) {
    final theme = Theme.of(context);
    final poll = item.poll;

    if (poll == null) return const SizedBox.shrink();

    final hasVoted = poll.myVote != null;
    
    // Размер картинок в зависимости от количества
    final imageSize = poll.options.length == 1
        ? 180.0
        : poll.options.length == 2
            ? 140.0
            : poll.options.length == 3
                ? 110.0
                : 85.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок
        Row(
          children: [
            Icon(Icons.poll_rounded, size: 14, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            const Text(
              'Опрос',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Вопрос по центру
        Center(
          child: Text(
            poll.question,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Картинки по центру (если есть)
        if (poll.options.any((o) => o.imagePath != null))
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: poll.options.asMap().entries.map((entry) {
              final option = entry.value;
              if (option.imagePath == null) return const SizedBox.shrink();
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    '${AuthService.baseUrl}/news/images/${option.imagePath}',
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: imageSize,
                        height: imageSize,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        if (poll.options.any((o) => o.imagePath != null))
          const SizedBox(height: 12),

        // Варианты ответов
        ...poll.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          return _PollOptionTile(
            option: option,
            index: index,
            totalVotes: poll.totalVotes,
            isMyVote: poll.myVote == index,
            hasVoted: hasVoted,
            onTap: hasVoted ? null : () => _handleVote(index),
          );
        }),

        // Описание опроса
        if (item.text != null && item.text!.isNotEmpty)
          Center(
            child: Text(
              item.text!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.3, fontSize: 16),
            ),
          ),
        const SizedBox(height: 10),

        // Общее количество голосов
        Row(
          children: [
            Text(
              '${poll.totalVotes} ${_pluralizeVotes(poll.totalVotes)}',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
            ),
            
            const Spacer(),
            
            // Кнопка отмены голоса
            if (hasVoted)
              TextButton.icon(
                onPressed: _removeVote,
                icon: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: theme.colorScheme.error,
                ),
                label: Text(
                  'Отменить голос',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.error,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _removeVote() async {
    try {
      await NewsService.removeVote(item.id);
      
      if (mounted) {
        final poll = item.poll!;
        final updatedOptions = List<PollOption>.from(poll.options);
        
        if (poll.myVote != null) {
          updatedOptions[poll.myVote!] = updatedOptions[poll.myVote!].copyWith(
            votes: updatedOptions[poll.myVote!].votes - 1,
          );
        }
        
        final updatedItem = item.copyWith(
          poll: poll.copyWith(
            options: updatedOptions,
            totalVotes: poll.totalVotes - 1,
            clearMyVote: true, // ← сбрасываем
          ),
        );
        
        print('Отмена: myVote = ${updatedItem.poll?.myVote}'); // ← отладка
        
        widget.onVoted?.call(updatedItem);
      }
    } catch (e) {
      // ...
    }
  }

  String _pluralizeVotes(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'голос';
    if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return 'голоса';
    }
    return 'голосов';
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

// ===== ВСПОМОГАТЕЛЬНЫЕ ВИДЖЕТЫ =====

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

class _FullScreenImageViewer extends StatefulWidget {
  final List<dynamic> chips;
  final int initialIndex;

  const _FullScreenImageViewer({
    required this.chips,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1} / ${widget.chips.length}'),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.chips.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          final imagePath = widget.chips[index]['image_path'];
          return InteractiveViewer(
            child: Image.network(
              '${AuthService.baseUrl}/news/images/$imagePath',
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.broken_image, color: Colors.white, size: 48),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _PollOptionTile extends StatelessWidget {
  final PollOption option;
  final int index;
  final int totalVotes;
  final bool isMyVote;
  final bool hasVoted;
  final VoidCallback? onTap;

  const _PollOptionTile({
    required this.option,
    required this.index,
    required this.totalVotes,
    required this.isMyVote,
    required this.hasVoted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = totalVotes > 0 ? (option.votes / totalVotes * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isMyVote
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant.withOpacity(0.3),
              width: isMyVote ? 2 : 1,
            ),
            color: isMyVote
                ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                : Colors.transparent,
          ),
          child: Stack(
            children: [
              if (hasVoted)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: percent / 100,
                        child: Container(
                          color: theme.colorScheme.primary.withOpacity(0.15),
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option.text,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isMyVote ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (hasVoted) ...[
                      const SizedBox(width: 8),
                      Text(
                        '$percent%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isMyVote ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                    if (isMyVote) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
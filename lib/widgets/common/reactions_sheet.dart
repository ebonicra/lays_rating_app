import 'package:flutter/material.dart';

import 'package:lays_rating/pages/profile/public_profile_page.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/utils/initials.dart';

enum ReactionsTab { likes, dislikes }

/// Универсальный пользователь реакции.
class ReactionUser {
  const ReactionUser({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
  });

  final int id;
  final String username;
  final String? displayName;
  final String? avatarUrl;
}

/// Универсальный результат: два списка — лайки и дизлайки.
class ReactionsData {
  const ReactionsData({required this.likes, required this.dislikes});

  final List<ReactionUser> likes;
  final List<ReactionUser> dislikes;
}

/// Универсальный bottom sheet со списком реакций —
/// работает и для новостей, и для комментариев.
class ReactionsSheet extends StatefulWidget {
  const ReactionsSheet({
    super.key,
    required this.loader,
    this.initialTab = ReactionsTab.likes,
  });

  final Future<ReactionsData> Function() loader;
  final ReactionsTab initialTab;

  static Future<void> show(
    BuildContext context, {
    required Future<ReactionsData> Function() loader,
    ReactionsTab initialTab = ReactionsTab.likes,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ReactionsSheet(
        loader: loader,
        initialTab: initialTab,
      ),
    );
  }

  @override
  State<ReactionsSheet> createState() => _ReactionsSheetState();
}

class _ReactionsSheetState extends State<ReactionsSheet> {
  late ReactionsTab _tab;
  ReactionsData? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await widget.loader();
      if (!mounted) return;
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('ReactionsSheet._load error: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Не удалось загрузить реакции';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Реакции',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            _buildTabs(theme),
            const SizedBox(height: 8),
            Expanded(child: _buildBody(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(ThemeData theme) {
    final likesCount = _data?.likes.length ?? 0;
    final dislikesCount = _data?.dislikes.length ?? 0;

    return Row(
      children: [
        Expanded(
          child: _TabButton(
            label: 'Лайки',
            count: likesCount,
            icon: Icons.favorite_rounded,
            color: Colors.red,
            isActive: _tab == ReactionsTab.likes,
            onTap: () => setState(() => _tab = ReactionsTab.likes),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _TabButton(
            label: 'Дизлайки',
            count: dislikesCount,
            icon: Icons.heart_broken_rounded,
            color: Colors.brown,
            isActive: _tab == ReactionsTab.dislikes,
            onTap: () => setState(() => _tab = ReactionsTab.dislikes),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _load,
              child: const Text('Попробовать снова'),
            ),
          ],
        ),
      );
    }

    final users = _tab == ReactionsTab.likes
        ? (_data?.likes ?? [])
        : (_data?.dislikes ?? []);

    if (users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _tab == ReactionsTab.likes
                ? 'Пока никто не лайкнул'
                : 'Пока никто не дизлайкнул',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: users.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        thickness: 1,
        color: theme.colorScheme.outlineVariant.withOpacity(0.3),
      ),
      itemBuilder: (context, index) {
        return _UserTile(user: users[index]);
      },
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeBg = color.withOpacity(0.12);
    final inactiveBg =
        theme.colorScheme.surfaceContainerHighest.withOpacity(0.4);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isActive ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? color : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              '$label ($count)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? color : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});

  final ReactionUser user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildAvatar(),
      title: Text(
        user.displayName ?? user.username,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('@${user.username}'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PublicProfilePage(userId: user.id),
          ),
        );
      },
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 22,
      backgroundImage: user.avatarUrl != null
          ? NetworkImage('${AuthService.baseUrl}${user.avatarUrl}')
          : null,
      child: user.avatarUrl == null
          ? Text(
              initialOf(user.displayName ?? user.username),
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
          : null,
    );
  }
}
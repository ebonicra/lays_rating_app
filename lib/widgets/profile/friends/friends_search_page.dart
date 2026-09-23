import 'package:flutter/material.dart';

import 'package:lays_rating/models/user.dart';
import 'package:lays_rating/models/user_brief.dart';
import 'package:lays_rating/services/follow_service.dart';
import 'package:lays_rating/services/user_service.dart';
import 'package:lays_rating/widgets/profile/friends/friends_mini_card.dart';

/// Страница поиска и просмотра пользователей.
class FriendsSearchPage extends StatefulWidget {
  const FriendsSearchPage({super.key});

  @override
  State<FriendsSearchPage> createState() => _FriendsSearchPageState();
}

class _FriendsSearchPageState extends State<FriendsSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<User>? _allUsers;
  List<User>? _filteredUsers;
  Set<int> _myFollowingIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        FollowService.getAllUsers(),
        _fetchMyFollowingIds(),
      ]);

      final users = results[0] as List<User>;
      final followingIds = results[1] as Set<int>;

      if (!mounted) return;
      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _myFollowingIds = followingIds;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('FriendsSearchPage._loadData error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<Set<int>> _fetchMyFollowingIds() async {
    final myId = UserService.currentUser?.id;
    if (myId == null) return {};

    try {
      final list = await FollowService.getFollowing(userId: myId);
      return list.map((u) => u.id).toSet();
    } catch (e) {
      debugPrint('FriendsSearchPage._fetchMyFollowingIds error: $e');
      return {};
    }
  }

  void _filter(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      setState(() => _filteredUsers = _allUsers);
      return;
    }

    setState(() {
      _filteredUsers = _allUsers?.where((user) {
        return user.username.toLowerCase().contains(trimmed) ||
            user.displayName.toLowerCase().contains(trimmed);
      }).toList();
    });
  }

  Future<void> _toggleFollow(UserBrief user, bool wasFollowing) async {
    setState(() {
      if (wasFollowing) {
        _myFollowingIds.remove(user.id);
      } else {
        _myFollowingIds.add(user.id);
      }
    });

    try {
      if (wasFollowing) {
        await FollowService.unfollowUser(user.id);
      } else {
        await FollowService.followUser(user.id);
      }
    } catch (e) {
      debugPrint('FriendsSearchPage._toggleFollow error: $e');
      if (!mounted) return;
      setState(() {
        if (wasFollowing) {
          _myFollowingIds.add(user.id);
        } else {
          _myFollowingIds.remove(user.id);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось выполнить действие'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: false,
          onChanged: _filter,
          decoration: const InputDecoration(
            hintText: 'Поиск по имени или username...',
            hintStyle: TextStyle(fontSize: 13),
            border: InputBorder.none,
          ),
        ),
        actions: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  _filter('');
                },
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final colorScheme = Theme.of(context).colorScheme;
    final users = _filteredUsers;
    if (users == null || users.isEmpty) {
      return Center(
        child: Text(
          _controller.text.isEmpty ? 'Нет пользователей' : 'Никого не нашли',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(6),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final brief = UserBrief.fromUser(user);

        return FriendsMiniCard(
          user: brief,
          isFollowing: _myFollowingIds.contains(brief.id),
          onToggleFollow: () => _toggleFollow(
            brief,
            _myFollowingIds.contains(brief.id),
          ),
          onReturn: _fetchMyFollowingIds,
        );
      },
    );
  }
}
import 'package:flutter/material.dart';

import 'package:lays_rating/models/user_brief.dart';
import 'package:lays_rating/services/follow_service.dart';
import 'package:lays_rating/services/user_service.dart';
import 'package:lays_rating/widgets/profile/friends/friends_list.dart';
import 'package:lays_rating/widgets/profile/friends/friends_tab_bar.dart';
import 'package:lays_rating/widgets/profile/friends/friends_search_page.dart';

/// Страница «Друзья и приятели»: подписки и подписчики.
class FriendsPage extends StatefulWidget {
  const FriendsPage({
    super.key,
    required this.userId,
  });

  final int userId;

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  List<UserBrief>? _following;
  List<UserBrief>? _followers;
  Set<int> _myFollowingIds = {};

  bool _isLoadingFollowing = true;
  bool _isLoadingFollowers = true;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

    _loadFollowing();
    _loadFollowers();
    _loadMyFollowing();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == 0) {
      _loadFollowing();
    } else {
      _loadFollowers();
    }
  }


  Future<void> _loadFollowing() async {
    setState(() => _isLoadingFollowing = true);

    try {
      final list = await FollowService.getFollowing(userId: widget.userId);
      if (!mounted) return;
      setState(() {
        _following = list;
        _isLoadingFollowing = false;
      });
    } catch (e) {
      debugPrint('FriendsPage._loadFollowing error: $e');
      if (!mounted) return;
      setState(() => _isLoadingFollowing = false);
    }
  }

  Future<void> _loadFollowers() async {
    setState(() => _isLoadingFollowers = true);

    try {
      final list = await FollowService.getFollowers(userId: widget.userId);
      if (!mounted) return;
      setState(() {
        _followers = list;
        _isLoadingFollowers = false;
      });
    } catch (e) {
      debugPrint('FriendsPage._loadFollowers error: $e');
      if (!mounted) return;
      setState(() => _isLoadingFollowers = false);
    }
  }

  Future<void> _loadMyFollowing() async {
    final myId = UserService.currentUser?.id;
    if (myId == null) return;

    try {
      final list = await FollowService.getFollowing(userId: myId);
      if (!mounted) return;
      setState(() {
        _myFollowingIds = list.map((u) => u.id).toSet();
      });
    } catch (e) {
      debugPrint('FriendsPage._loadMyFollowing error: $e');
    }
  }

  // === ПОДПИСКА/ОТПИСКА ===

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
      debugPrint('FriendsPage._toggleFollow error: $e');
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

  // === ПОИСК ===

  Future<void> _openSearch() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FriendsSearchPage()),
    );
    if (!mounted) return;

    // Тихо перезагружаем всё в фоне — UI уже показывает старые данные
    _loadFollowing();
    _loadFollowers();
    _loadMyFollowing();
  }

  // === BUILD ===

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Друзья и приятели'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _openSearch,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: FriendsTabBar(controller: _tabController),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FriendsList(
            users: _following,
            isLoading: _isLoadingFollowing,
            emptyText: 'Нет подписок',
            onRefresh: _loadFollowing,
            myFollowingIds: _myFollowingIds,
            onToggleFollow: _toggleFollow,
            onReturn: _loadMyFollowing,
          ),
          FriendsList(
            users: _followers,
            isLoading: _isLoadingFollowers,
            emptyText: 'Нет подписчиков',
            onRefresh: _loadFollowers,
            myFollowingIds: _myFollowingIds,
            onToggleFollow: _toggleFollow,
            onReturn: _loadMyFollowing,
          ),
        ],
      ),
    );
  }
}
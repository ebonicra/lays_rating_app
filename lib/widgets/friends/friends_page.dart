import 'package:flutter/material.dart';

import 'package:lays_rating/models/user_brief.dart';
import 'package:lays_rating/services/follow_service.dart';

import 'package:lays_rating/widgets/friends/friends_list.dart';
import 'package:lays_rating/widgets/friends/friends_tab_bar.dart';
import 'package:lays_rating/pages/user_search_page.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({
    super.key,
    required this.userId,
  });

  final int userId;

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  late Future<List<UserBrief>> _followingFuture;
  late Future<List<UserBrief>> _followersFuture;

  @override
  void initState() {
    super.initState();
    _followingFuture = FollowService.getFollowing(userId: widget.userId);
    _followersFuture = FollowService.getFollowers(userId: widget.userId);
  }

  void _reload() {
    setState(() {
      _followingFuture = FollowService.getFollowing(userId: widget.userId);
      _followersFuture = FollowService.getFollowers(userId: widget.userId);
    });
  }

  Future<void> _openSearch() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserSearchPage()),
    );
    if (!mounted) return;
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Друзья и приятели'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _openSearch,
            ),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: FriendsTabBar(),
          ),
        ),
        body: TabBarView(
          children: [
            FriendsList(
              future: _followingFuture,
              emptyText: 'Нет подписок',
              onRefresh: () async => _reload(),
            ),
            FriendsList(
              future: _followersFuture,
              emptyText: 'Нет подписчиков',
              onRefresh: () async => _reload(),
            ),
          ],
        ),
      ),
    );
  }
}
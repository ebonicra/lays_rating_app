import 'package:flutter/material.dart';
import 'package:lays_rating/models/user.dart';
import 'package:lays_rating/services/follow_service.dart';
import 'package:lays_rating/models/follow_user.dart';
import 'package:lays_rating/services/auth_service.dart';

import 'package:lays_rating/widgets/user_card.dart';


import 'profile/public_profile_page.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<User>? _allUsers; // ← все пользователи
  List<User>? _filteredUsers; // ← отфильтрованные
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Загружаем всех пользователей при открытии страницы
  Future<void> _loadAllUsers() async {
    setState(() => _isLoading = true);

    try {
      final users = await FollowService.getAllUsers(); // ← нужен новый метод
      if (mounted) {
        setState(() {
          _allUsers = users;
          _filteredUsers = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Фильтруем на клиенте (мгновенно, без запросов)
  void _filter(String query) {
    if (query.trim().isEmpty) {
      setState(() => _filteredUsers = _allUsers);
      return;
    }

    setState(() {
      _filteredUsers = _allUsers?.where((user) {
        return user.username.toLowerCase().contains(query.toLowerCase()) ||
            user.displayName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: false, // ← убрали автофокус, чтобы сразу видеть список
          onChanged: _filter,
          decoration: InputDecoration(
            hintText: 'Поиск по username...',
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                _filter('');
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

    if (_filteredUsers == null || _filteredUsers!.isEmpty) {
      return Center(
        child: Text(
          _controller.text.isEmpty ? 'Нет пользователей' : 'Никого не нашли',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _filteredUsers!.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers![index];
        return UserCard(user: FollowUser.fromUser(user));
      },
    );
  }
}


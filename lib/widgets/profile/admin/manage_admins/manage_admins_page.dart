import 'package:flutter/material.dart';

import 'package:lays_rating/models/user.dart';
import 'package:lays_rating/widgets/common/user_list_tile.dart';
import 'package:lays_rating/widgets/common/user_action_button.dart';
import 'package:lays_rating/services/admin_service.dart';
import 'package:lays_rating/services/follow_service.dart';
import 'package:lays_rating/services/user_service.dart';

/// Управление админами (только для супер-админов).
class ManageAdminsPage extends StatefulWidget {
  const ManageAdminsPage({super.key});

  @override
  State<ManageAdminsPage> createState() => _ManageAdminsPageState();
}

class _ManageAdminsPageState extends State<ManageAdminsPage> {
  List<User>? _allUsers;
  List<User>? _filteredUsers;
  Set<int> _adminIds = {};
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkAccess() async {
    if (UserService.currentUser?.isSuperAdmin != true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Нет доступа')
        ),
      );
      Navigator.pop(context);
      return;
    }
    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        AdminService.getAdmins(),
        FollowService.getAllUsers(),
      ]);

      final admins = results[0];
      final allUsers = results[1];

      if (!mounted) return;
      setState(() {
        _adminIds = admins.map((a) => a.id).toSet();
        _allUsers = allUsers;
        _filteredUsers = allUsers;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('ManageAdminsPage._loadData error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
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

  Future<void> _toggleAdmin(User user) async {
    final wasAdmin = _adminIds.contains(user.id);

    try {
      if (wasAdmin) {
        await AdminService.removeAdmin(user.id);
      } else {
        await AdminService.makeAdmin(user.id);
      }

      if (!mounted) return;
      setState(() {
        if (wasAdmin) {
          _adminIds.remove(user.id);
        } else {
          _adminIds.add(user.id);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            wasAdmin
                ? '${user.username} больше не админ'
                : '${user.username} теперь админ',
          ),
        ),
      );
    } catch (e) {
      debugPrint('ManageAdminsPage._toggleAdmin error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Не удалось изменить права')
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Управление админами')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0), 
            child: TextField(
              controller: _searchController,
              onChanged: _filter,
              decoration: InputDecoration(
                hintText: 'Поиск по имени или username...',
                hintStyle: const TextStyle(fontSize: 13),
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final users = _filteredUsers;
    if (users == null || users.isEmpty) {
      return const Center(child: Text('Нет пользователей'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(6),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return UserListTile(
          userId: user.id,
          displayName: user.displayName,
          username: user.username,
          avatarUrl: user.avatarUrl,
          trailing: UserActionButton(
            label: _adminIds.contains(user.id) ? 'Снять' : 'Назначить',
            active: _adminIds.contains(user.id),
            onTap: () => _toggleAdmin(user),
          ),
        );
      },
    );
  }
}

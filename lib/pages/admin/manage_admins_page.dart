import 'package:flutter/material.dart';
import 'package:lays_rating/models/user.dart';
import 'package:lays_rating/services/admin_service.dart';
import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/services/follow_service.dart';

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
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final admins = await AdminService.getAdmins();
      final allUsers = await FollowService.getAllUsers();

      if (mounted) {
        setState(() {
          _adminIds = admins.map((a) => a.id).toSet();
          _allUsers = allUsers;
          _filteredUsers = allUsers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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

  Future<void> _toggleAdmin(User user) async {
    try {
      if (_adminIds.contains(user.id)) {
        await AdminService.removeAdmin(user.id);
        if (mounted) {
          setState(() => _adminIds.remove(user.id));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${user.username} больше не админ')),
          );
        }
      } else {
        await AdminService.makeAdmin(user.id);
        if (mounted) {
          setState(() => _adminIds.add(user.id));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${user.username} теперь админ')),
          );
        }
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление админами'),
      ),
      body: Column(
        children: [
          // Поиск
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: _filter,
              decoration: InputDecoration(
                hintText: 'Поиск по username...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          // Список
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers == null || _filteredUsers!.isEmpty
                    ? const Center(child: Text('Нет пользователей'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _filteredUsers!.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers![index];
                          final isAdmin = _adminIds.contains(user.id);
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundImage: user.avatarUrl != null
                                    ? NetworkImage('${AuthService.baseUrl}${user.avatarUrl}')
                                    : null,
                                child: user.avatarUrl == null
                                    ? Text(
                                        user.displayName.substring(0, 1).toUpperCase(),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      )
                                    : null,
                              ),
                              title: Text(
                                user.displayName,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text('@${user.username}'),
                              trailing: ElevatedButton(
                                onPressed: () => _toggleAdmin(user),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isAdmin
                                      ? theme.colorScheme.surfaceContainerHighest
                                      : theme.colorScheme.primary,
                                  foregroundColor: isAdmin
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  minimumSize: const Size(110, 32),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  isAdmin ? 'Снять' : 'Назначить',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
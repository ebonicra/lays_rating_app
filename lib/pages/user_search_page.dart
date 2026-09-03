import 'package:flutter/material.dart';
import 'package:lays_rating/models/user.dart';
import 'package:lays_rating/services/follow_service.dart';
import 'package:lays_rating/services/auth_service.dart';

import 'package:lays_rating/widgets/user_card.dart';


import '../pages/public_profile_page.dart';

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
        return UserCard(user: user);
      },
    );
  }
}




// class _UserCard extends StatefulWidget {
//   final User user;
//   const _UserCard({required this.user});

//   @override
//   State<_UserCard> createState() => _UserCardState();
// }

// class _UserCardState extends State<_UserCard> {
//   bool? _isFollowing;
//   bool _isLoading = false;
//   bool _isPressed = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkFollowStatus();
//   }

//   Future<void> _checkFollowStatus() async {
//     try {
//       final status = await FollowService.checkFollowing(widget.user.id);
//       if (mounted) {
//         setState(() => _isFollowing = status.isFollowing);
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isFollowing = false);
//       }
//     }
//   }

//   Future<void> _toggleFollow() async {
//     if (_isLoading || _isFollowing == null) return;

//     setState(() => _isLoading = true);
//     try {
//       if (_isFollowing == true) {
//         await FollowService.unfollowUser(widget.user.id);
//         if (mounted) setState(() => _isFollowing = false);
//       } else {
//         await FollowService.followUser(widget.user.id);
//         if (mounted) setState(() => _isFollowing = true);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Не удалось выполнить действие')),
//         );
//       }
//     }
//     if (mounted) setState(() => _isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Card(
//       child: ListTile(
//         leading: CircleAvatar(
//           radius: 16,
//           backgroundColor: theme.colorScheme.primaryContainer,
//           backgroundImage: widget.user.avatarUrl != null
//               ? NetworkImage('${AuthService.baseUrl}${widget.user.avatarUrl}')
//               : null,
//           child: widget.user.avatarUrl == null
//               ? Text(
//                   widget.user.displayName.substring(0, 1).toUpperCase(),
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: theme.colorScheme.primary,
//                   ),
//                 )
//               : null,
//         ),
//         title: Text(
//           widget.user.displayName,
//           style: const TextStyle(fontWeight: FontWeight.w600),
//         ),
//         subtitle: Text('@${widget.user.username}'),
//         trailing: GestureDetector(
//           onTapDown: (_) => setState(() => _isPressed = true),
//           onTapUp: (_) => setState(() => _isPressed = false),
//           onTapCancel: () => setState(() => _isPressed = false),
//           child: AnimatedScale(
//             scale: _isPressed ? 0.80 : 1.0,
//             duration: const Duration(milliseconds: 110),
//             child: _isFollowing == true
//               ? ElevatedButton(
//                   onPressed: _toggleFollow,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     minimumSize: const Size(100, 32),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     elevation: 2,
//                   ),
//                   child: const Text(
//                     'Отписаться',
//                     style: TextStyle(fontSize: 12),
//                   ),
//                 )
//               : ElevatedButton(
//                   onPressed: _toggleFollow,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     minimumSize: const Size(100, 32),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     backgroundColor: theme.colorScheme.inversePrimary,
//                     foregroundColor: theme.colorScheme.onSurface,
//                     elevation: 2,
//                   ),
//                   child: const Text(
//                     'Подписаться',
//                     style: TextStyle(fontSize: 12),
//                   ),
//                 ),
//           ),
//         ),

//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => PublicProfilePage(userId: widget.user.id),
//             ),
//           ).then((_) {
//             // После возврата — перепроверяем статус подписки
//             if (mounted) {
//               setState(() {
//                 _checkFollowStatus(); // ← перезагружаем статус
//               });
//             }
//           });
//         },
//       ),
//     );
//   }
// }
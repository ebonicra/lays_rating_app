// pages/friends_page.dart
import 'package:flutter/material.dart';
import 'package:lays_rating/models/user.dart';
import 'package:lays_rating/models/follow_user.dart';
import 'package:lays_rating/services/follow_service.dart';
import '../services/auth_service.dart';
import '../pages/user_search_page.dart';

import 'package:lays_rating/widgets/user_card.dart';



class FriendsPage extends StatefulWidget {
  final int userId;

  const FriendsPage({
    super.key,
    required this.userId,
  });

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  late Future<List<FollowUser>> _followingFuture;
  late Future<List<FollowUser>> _followersFuture;


  @override
  void initState() {
    super.initState();
    _reloadFutures();  // ← инициализируем при старте
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _reloadFutures() {
    setState(() {  // ← ВОТ ЭТО ОБЯЗАТЕЛЬНО
      _followingFuture = FollowService.getFollowing(userId: widget.userId);
      _followersFuture = FollowService.getFollowers(userId: widget.userId);
    });
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UserSearchPage(),
                  ),
                ).then((_) {
                  if (mounted) {
                    setState(() {
                      _reloadFutures();
                    });
                  }
                });
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab, 
                  indicator: BoxDecoration(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  labelColor: Colors.white, // ← цвет активного текста
                  unselectedLabelColor: Colors.grey.shade600, // ← цвет неактивного текста
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 15,
                  ),
                  dividerColor: Colors.transparent, // ← убираем линию снизу
                  tabs: const [
                    Tab(height: 44, text: 'Подписки'),
                    Tab(height: 44, text: 'Подписчики'),
                  ],
                ),
              ),
            ),
          ),
        ),

        body: TabBarView(
          children: [
            _UsersList(future: _followingFuture, emptyText: 'Нет подписок'),
            _UsersList(future: _followersFuture, emptyText: 'Нет подписчиков'),
          ],
        ),
      ),
    );
  }
}

class _UsersList extends StatelessWidget {
  final Future<List<FollowUser>> future;
  final String emptyText;

  const _UsersList({
    required this.future,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FollowUser>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Не удалось загрузить'),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => (context as Element).markNeedsBuild(),
                  child: const Text('Попробовать снова'),
                ),
              ],
            ),
          );
        }

        final users = snapshot.data;
        if (users == null || users.isEmpty) {
          return Center(
            child: Text(
              emptyText,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Для pull-to-refresh можно пересоздать Future
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              return UserCard(user: users[index]);
            },
          ),
        );
      },
    );
  }
}


// class _UserCard extends StatelessWidget {
//   final User user;

//   const _UserCard({required this.user});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Card(
//       child: ListTile(
//         leading: CircleAvatar(
//           radius: 22,
//           backgroundColor: theme.colorScheme.primaryContainer,
//           backgroundImage: user.avatarUrl != null
//               ? NetworkImage('${AuthService.baseUrl}${user.avatarUrl}')
//               : null,
//           child: user.avatarUrl == null
//               ? Text(
//                   user.displayName.substring(0, 1).toUpperCase(),
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: theme.colorScheme.primary,
//                   ),
//                 )
//               : null,
//         ),
//         title: Text(
//           user.displayName,
//           style: const TextStyle(fontWeight: FontWeight.w600),
//         ),
//         subtitle: Text('@${user.username}'),
//         trailing: const Icon(Icons.chevron_right),
//         onTap: () {
//           // TODO: открыть профиль пользователя
//         },
//       ),
//     );
//   }
// }


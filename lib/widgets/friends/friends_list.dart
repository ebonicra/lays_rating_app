import 'package:flutter/material.dart';

import 'package:lays_rating/models/user_brief.dart';
import 'package:lays_rating/widgets/user_card.dart';

/// Список пользователей с загрузкой, обработкой ошибок, пустого состояния
/// и pull-to-refresh.
class FriendsList extends StatelessWidget {
  const FriendsList({
    super.key,
    required this.future,
    required this.emptyText,
    required this.onRefresh,
  });

  final Future<List<UserBrief>> future;
  final String emptyText;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<UserBrief>>(
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
                  onPressed: onRefresh,
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
                color: colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
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
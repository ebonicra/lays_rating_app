import 'package:flutter/material.dart';

/// Таб-бар с двумя вкладками: «Подписки» и «Подписчики».
class FriendsTabBar extends StatelessWidget {
  const FriendsTabBar({
    super.key,
    required this.controller,
  });

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(25),
        ),
        child: TabBar(
          controller: controller,   // ← передаём
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: colorScheme.inversePrimary,
            borderRadius: BorderRadius.circular(25),
          ),
          labelColor: colorScheme.onPrimary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 15,
          ),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(height: 44, text: 'Подписки'),
            Tab(height: 44, text: 'Подписчики'),
          ],
        ),
      ),
    );
  }
}
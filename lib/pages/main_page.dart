import 'package:flutter/material.dart';

import 'package:lays_rating/pages/chips/chips_page.dart';
import 'package:lays_rating/pages/game_page.dart';
import 'package:lays_rating/pages/news_page.dart';
import 'package:lays_rating/pages/profile_page.dart';
import 'package:lays_rating/pages/filter_page.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const int _chipsIndex = 2;
  int _currentIndex = _chipsIndex;

  static const List<Widget> _pages = [
    GamePage(),
    NewsPage(),
    ChipsPage(),
    FilterPage(),
    ProfilePage(),
  ];

  void _openChipsPage() {
    setState(() => _currentIndex = _chipsIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      floatingActionButton: Transform.translate(
        offset: const Offset(0, 15),
        child: SizedBox(
          width: 75,
          height: 75,
          child: FloatingActionButton(
            onPressed: _openChipsPage,
            shape: const CircleBorder(),
            child: const Icon(Icons.local_fire_department),
          ),
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.noAnimation,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        iconSize: 20,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports),
            label: 'Игра',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'Новости',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(width: 48),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tune),
            label: 'Фильтры',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
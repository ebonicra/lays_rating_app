import 'package:flutter/material.dart';

import 'package:lays_rating/pages/chips/chips_page.dart';
import 'package:lays_rating/pages/game/game_page.dart';
import 'package:lays_rating/pages/news/news_page.dart';
import 'package:lays_rating/pages/profile/profile_page.dart';
import 'package:lays_rating/pages/filters/filter_page.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const int _chipsIndex = 2;
  int _currentIndex = _chipsIndex;

  void _openChipsPage() {
    setState(() => _currentIndex = _chipsIndex);
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return const GamePage();
      case 1:
        return const NewsPage();
      case 2:
        return const ChipsPage();
      case 3:
        return const FilterPage();
      case 4:
        return const ProfilePage();
      default:
        return const ChipsPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentPage(),

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
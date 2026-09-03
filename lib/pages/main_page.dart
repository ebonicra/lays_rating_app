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
  static const int chipsIndex = 2;
  int currentIndex = chipsIndex;

  static const List<Widget> pages = [
    GamePage(),
    NewsPage(),
    ChipsPage(),
    FilterPage(),
    ProfilePage(),
  ];

  void openChipsPage() {
    setState(() {
      currentIndex = chipsIndex;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: pages[currentIndex],

      floatingActionButton: Transform.translate(
        offset: const Offset(0, 15), // ← вниз
        child: SizedBox(
          width: 75,
          height: 75,
          child: FloatingActionButton(
            onPressed: openChipsPage,
            shape: const CircleBorder(),
            child: const Icon(Icons.local_fire_department),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        iconSize: 20.0,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        type: BottomNavigationBarType.fixed,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports),
            label: "Игра",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: "Новости",
          ),

          BottomNavigationBarItem(
            icon: SizedBox.shrink(),
            label: "",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.tune),
            label: "Фильтры",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Профиль",
          ),
        ],
      ),

    );
  }
}
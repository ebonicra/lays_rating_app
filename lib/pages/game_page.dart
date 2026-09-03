import 'package:flutter/material.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Игра'),
      ),
      body: const Center(
        child: Text(
          "Игра",
          style: TextStyle(fontSize: 32),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

// Кнопка выхода из аккаунта.
class ProfileLogoutButton extends StatelessWidget {
  const ProfileLogoutButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.logout),
        label: const Text('Выйти'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(14),
        ),
      ),
    );
  }
}
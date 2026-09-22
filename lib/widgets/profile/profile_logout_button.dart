import 'package:flutter/material.dart';

/// Кнопка выхода из аккаунта.
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

Future<bool> confirmLogout(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Выйти из аккаунта?'),
      content: const Text(
        'Вам придётся войти заново, чтобы продолжить.',
        textAlign: TextAlign.center,
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Отмена'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Выйти'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return result ?? false;
}
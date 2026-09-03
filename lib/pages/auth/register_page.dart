import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

import '../main_page.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}



class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  Future<void> register() async {
    try {
      await AuthService.register(
        username: usernameController.text,
        password: passwordController.text,
        displayName: nameController.text,
      );

      await AuthService.login(
        username: usernameController.text,
        password: passwordController.text,
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const MainPage(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Ошибка: $e",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Регистрация",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
              ),
            ),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Имя",
              ),
            ),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Пароль",
              ),
            ),

            const SizedBox(height:20),
            ElevatedButton(
              onPressed: register,
              child: const Text(
                "Создать аккаунт",
              ),
            )
          ],
        ),
      ),
    );
  }
}
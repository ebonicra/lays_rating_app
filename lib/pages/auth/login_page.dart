import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
// import '../chips/chips_page.dart';
import '../auth/register_page.dart';
import '../main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    try {
      await AuthService.login(
        username: usernameController.text,
        password: passwordController.text,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainPage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Ошибка входа: $e",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Вход"),
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
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Пароль",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: login,
              child: const Text(
                "Войти",
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterPage(),
                  ),
                );
              },
              child: const Text(
                "Нет аккаунта? Зарегистрироваться",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
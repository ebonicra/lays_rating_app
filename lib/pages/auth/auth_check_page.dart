import 'package:flutter/material.dart';

import 'package:lays_rating/services/auth_service.dart';
import 'package:lays_rating/pages/main_page.dart';
import 'package:lays_rating/pages/auth/login_page.dart';


class AuthCheckPage extends StatefulWidget {
  const AuthCheckPage({super.key});

  @override
  State<AuthCheckPage> createState() => _AuthCheckPageState();
}


class _AuthCheckPageState extends State<AuthCheckPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  Future<void> _checkAuth() async {
    Widget nextPage;
    try {
      final token = await AuthService.getToken();
      nextPage = token != null ? const MainPage() : const LoginPage();
    } catch (e) {
      debugPrint('AuthCheckPage._checkAuth error: $e');
      nextPage = const LoginPage();
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator()
      ),
    );
  }
}
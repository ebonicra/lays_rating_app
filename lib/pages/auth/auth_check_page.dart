import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../main_page.dart';
import 'login_page.dart';


class AuthCheckPage extends StatefulWidget {
  const AuthCheckPage({
    super.key,
  });

  @override
  State<AuthCheckPage> createState() =>
      _AuthCheckPageState();
}


class _AuthCheckPageState extends State<AuthCheckPage> {

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  Future<void> checkAuth() async {
    final token = await AuthService.getToken();
    if (!mounted) return;
    if (token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainPage(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';


class AuthService {
  static const String baseUrl = "http://192.168.0.104:8000";

  // Регистрация
  static Future<User> register({
    required String username,
    required String password,
    required String displayName,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
        "display_name": displayName,
      }),
    );

    if (response.statusCode != 200) {
      try {
        final data = jsonDecode(response.body);
        throw Exception(data["detail"] ?? "Registration failed");
      } catch (_) {
        throw Exception("Registration failed");
      }
    }

    return User.fromJson(jsonDecode(response.body));
  }

  // Вход в систему
  static Future<String> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Login failed");
    }

    final data = jsonDecode(response.body);
    final token = data["access_token"];
    await saveToken(token);
    return token;
  }

  // ТОКЕН
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  // Получить токен из SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // Выход из системы — удаляет токен
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }
}
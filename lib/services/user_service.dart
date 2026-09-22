import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user.dart';
import 'auth_service.dart';


class UserService {
  static User? currentUser;

  static Future<User> getCurrentUser() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.get(
      Uri.parse("${AuthService.baseUrl}/users/me"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load user");
    }

    final user = User.fromJson(jsonDecode(response.body));
    currentUser = user;
    return user;
  }

  static Future<User> getUserById(int userId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.get(
      Uri.parse("${AuthService.baseUrl}/users/$userId"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load user");
    }
    return User.fromJson(jsonDecode(response.body));
  }

  static Future<User> updateProfile({
    String? displayName,
    String? username,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final body = <String, dynamic>{};
    if (displayName != null) body['display_name'] = displayName;
    if (username != null) body['username'] = username;

    final response = await http.put(
      Uri.parse('${AuthService.baseUrl}/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractError(response, 'Не удалось сохранить профиль'));
    }

    final user = User.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
    currentUser = user;
    return user;
  }

  static Future<void> deleteAccount() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http
        .delete(
          Uri.parse('${AuthService.baseUrl}/users/me'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(_extractError(response, 'Не удалось удалить аккаунт'));
    }

    currentUser = null;
  }

  static String _extractError(http.Response response, String fallback) {
    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is Map<String, dynamic>) {
        final detail = data['detail'];
        if (detail is String && detail.isNotEmpty) return detail;
      }
    } catch (_) {}
    return fallback;
  }
}
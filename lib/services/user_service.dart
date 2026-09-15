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
    if (token == null) throw Exception("No token");

    final body = <String, dynamic>{};
    if (displayName != null) body['display_name'] = displayName;
    if (username != null) body['username'] = username;

    final response = await http.put(
      Uri.parse("${AuthService.baseUrl}/users/me"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      try {
        final data = jsonDecode(response.body);
        throw Exception(data["detail"] ?? "Failed to update profile");
      } catch (_) {
        throw Exception("Failed to update profile");
      }
    }

    final user = User.fromJson(jsonDecode(response.body));
    currentUser = user;
    return user;
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthService {
  // static const String baseUrl = "http://10.0.2.2:8000";
  static const String baseUrl = "http://192.168.0.104:8000";
  // static const String baseUrl = "http://10.57.248.41:8000";

  static Future<User> register({
    required String username,
    required String password,
    required String displayName,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/users/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
        "display_name": displayName,
      }),
    );

    if(response.statusCode != 200){
      throw Exception("Registration failed");
    }

    return User.fromJson(
      jsonDecode(response.body),
    );
  }


  static Future<String> login({
    required String username,
    required String password,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/users/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );


    if(response.statusCode != 200){
      throw Exception("Login failed");
    }

    final data = jsonDecode(response.body);
    final token = data["access_token"];
    await saveToken(token);
    return token;
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      "token",
      token,
    );
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }
}
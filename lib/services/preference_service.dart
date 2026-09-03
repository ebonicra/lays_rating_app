import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';


class PreferenceService {
  static const String baseUrl = AuthService.baseUrl;

  static Future<List<String>> getPreferences() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/preferences"),
      headers: {"Authorization": "Bearer $token"},
    );

    if(response.statusCode != 200){
      throw Exception("Failed to load preferences");
    }

    final data = jsonDecode(response.body);
    return List<String>.from(
      data["categories"],
    );
  }


  static Future<void> updatePreferences(List<String> categories) async {
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse("$baseUrl/preferences"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },

      body: jsonEncode({
        "categories": categories,
      }),
    );

    if(response.statusCode != 200){
      throw Exception("Failed to update preferences");
    }
  }
}
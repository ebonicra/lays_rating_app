import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';


class UserFilters {
  final List<String> categories;
  final bool russiaOnly;
  final bool availableOnly;

  const UserFilters({
    required this.categories,
    required this.russiaOnly,
    required this.availableOnly,
  });

  factory UserFilters.fromJson(Map<String, dynamic> json) {
    return UserFilters(
      categories: List<String>.from(json['categories'] ?? []),
      russiaOnly: json['russia_only'] ?? false,
      availableOnly: json['available_only'] ?? false,
    );
  }
}


class PreferenceService {
  static const String baseUrl = AuthService.baseUrl;

  // Получить все настройки фильтров
  static Future<UserFilters> getPreferences() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/preferences"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load preferences");
    }

    final data = jsonDecode(response.body);
    return UserFilters.fromJson(data);
  }

  // Получить только категории (для совместимости)
  static Future<List<String>> getCategories() async {
    final filters = await getPreferences();
    return filters.categories;
  }

  // Обновить только категории
  static Future<void> updateCategories(List<String> categories) async {
    final current = await getPreferences();
    await updatePreferences(
      categories: categories,
      russiaOnly: current.russiaOnly,
      availableOnly: current.availableOnly,
    );
  }

  // Обновить всё
  static Future<void> updatePreferences({
    List<String>? categories,
    bool? russiaOnly,
    bool? availableOnly,
  }) async {
    final token = await AuthService.getToken();
    
    final body = <String, dynamic>{};
    if (categories != null) body['categories'] = categories;
    if (russiaOnly != null) body['russia_only'] = russiaOnly;
    if (availableOnly != null) body['available_only'] = availableOnly;

    final response = await http.put(
      Uri.parse("$baseUrl/preferences"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update preferences");
    }
  }
}
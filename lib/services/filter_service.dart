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

class FilterService {
  static const String baseUrl = AuthService.baseUrl;

  static Future<UserFilters> getFilters() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.get(
      Uri.parse('$baseUrl/filters'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load filters');
    }
    return UserFilters.fromJson(jsonDecode(response.body));
  }

  static Future<List<String>> getCategories() async {
    final filters = await getFilters();
    return filters.categories;
  }

  static Future<void> updateCategories(List<String> categories) async {
    final current = await getFilters();
    await updateFilters(
      categories: categories,
      russiaOnly: current.russiaOnly,
      availableOnly: current.availableOnly,
    );
  }

  static Future<void> updateFilters({
    List<String>? categories,
    bool? russiaOnly,
    bool? availableOnly,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final body = <String, dynamic>{};
    if (categories != null) body['categories'] = categories;
    if (russiaOnly != null) body['russia_only'] = russiaOnly;
    if (availableOnly != null) body['available_only'] = availableOnly;

    final response = await http.put(
      Uri.parse('$baseUrl/filters'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update filters');
    }
  }
}
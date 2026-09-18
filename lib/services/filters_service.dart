import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:lays_rating/models/user_filters.dart';
import 'package:lays_rating/services/auth_service.dart';


class FiltersService {
  FiltersService._();

  static Future<UserFilters> getFilters() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http
        .get(
          Uri.parse('${AuthService.baseUrl}/filters'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Не удалось загрузить фильтры (${response.statusCode})',
      );
    }

    return UserFilters.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  static Future<UserFilters> updateFilters({
    List<String>? filters,
    bool? russiaOnly,
    bool? availableOnly,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final body = <String, dynamic>{};
    if (filters != null) body['filters'] = filters;
    if (russiaOnly != null) body['russia_only'] = russiaOnly;
    if (availableOnly != null) body['available_only'] = availableOnly;

    final response = await http
        .put(
          Uri.parse('${AuthService.baseUrl}/filters'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Не удалось обновить фильтры (${response.statusCode})',
      );
    }

    return UserFilters.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }
}
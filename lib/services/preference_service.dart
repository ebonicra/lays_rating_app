import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chip_preference.dart';
import 'auth_service.dart';


class PreferenceService {
  static const String baseUrl = AuthService.baseUrl;

  static Future<ChipPreference> getPreference(int chipId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.get(
      Uri.parse('$baseUrl/preferences/$chipId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load preference');
    }

    return ChipPreference.fromJson(jsonDecode(response.body));
  }

  static Future<ChipPreference> updatePreference({
    required int chipId,
    int? rating,
    bool? isFavorite,
    bool? isTried,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.put(
      Uri.parse('$baseUrl/preferences/$chipId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        if (rating != null) 'rating': rating,
        if (isFavorite != null) 'is_favorite': isFavorite,
        if (isTried != null) 'is_tried': isTried,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update preference');
    }

    return ChipPreference.fromJson(jsonDecode(response.body));
  }

  static Future<ChipPreference> deleteRating(int chipId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.delete(
      Uri.parse('$baseUrl/preferences/$chipId/rating'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось удалить оценку');
    }
    return ChipPreference.fromJson(jsonDecode(response.body));
  }
}
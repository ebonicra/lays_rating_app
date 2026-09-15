import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lays_rating/models/chip.dart';

import 'auth_service.dart';

class RatingService {
  static const String baseUrl = AuthService.baseUrl;

  static Future<ChipRating> sendRating({
    required int chipId,
    required int value,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/ratings/"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "chip_id": chipId,
        "user_id": 1,
        "value": value,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to send rating");
    }

    final json = jsonDecode(response.body);
    return ChipRating.fromJson(json);
  }
}
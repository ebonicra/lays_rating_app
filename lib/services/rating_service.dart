import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lays_rating/models/chip.dart';

import 'auth_service.dart';

class RatingService {
  static const String baseUrl = AuthService.baseUrl;
  // static const String baseUrl = "http://10.0.2.2:8000";
  // static const String baseUrl = "http://127.0.0.1:8000";

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
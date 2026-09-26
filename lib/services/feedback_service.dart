import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:lays_rating/models/feedback.dart';
import 'auth_service.dart';

class FeedbackService {
  static Future<void> send({
    required FeedbackType type,
    required String text,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/feedback'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'type': type.value,
        'text': text,
      }),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(data['detail'] ?? 'Не удалось отправить');
    }
  }
}
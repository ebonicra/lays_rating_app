import 'dart:convert';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

class GameScoreResult {
  const GameScoreResult({
    required this.bestScore,
    required this.isNewRecord,
  });

  final int bestScore;
  final bool isNewRecord;
}

class GameService {
  static Future<GameScoreResult> saveScore(int score) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/game/records'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'score': score}),
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось сохранить рекорд');
    }

    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return GameScoreResult(
      bestScore: data['best_score'] as int? ?? score,
      isNewRecord: data['is_new_record'] as bool? ?? false,
    );
  }
}
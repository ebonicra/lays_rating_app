import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/news_item.dart';
import 'auth_service.dart';

class NewsService {
  static Future<List<NewsItem>> getFeed() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.get(
      Uri.parse("${AuthService.baseUrl}/news/feed"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load feed");
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    return data.map((item) => NewsItem.fromJson(item)).toList();
  }

  static Future<void> vote(int newsId, int optionIndex) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.post(
      Uri.parse("${AuthService.baseUrl}/news/$newsId/vote?option_index=$optionIndex"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Не удалось проголосовать');
    }
  }

  static Future<void> removeVote(int newsId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.delete(
      Uri.parse("${AuthService.baseUrl}/news/$newsId/vote"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Не удалось отменить голос');
    }
  }
}
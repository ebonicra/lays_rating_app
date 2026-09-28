import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:lays_rating/models/feedback.dart';
import 'package:lays_rating/models/feedback_item.dart';
import 'auth_service.dart';

class FeedbackService {
  // ===== Пользовательские =====

  static Future<String> uploadImage(String filePath) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final uri = Uri.parse('${AuthService.baseUrl}/feedback/images');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Не удалось загрузить картинку');
    }

    final data = jsonDecode(body);
    return data['image_path'] as String;
  }

  static Future<void> send({
    required FeedbackType type,
    required String title,
    required String text,
    List<String> imagePaths = const [],
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
        'title': title,
        'text': text,
        'image_paths': imagePaths,
      }),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(data['detail'] ?? 'Не удалось отправить');
    }
  }

  // ===== Админские =====

  static Future<FeedbackItem> setReadStatus(
    int feedbackId, {
    required bool isRead,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.put(
      Uri.parse('${AuthService.baseUrl}/admin/feedback/$feedbackId/read'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'is_read': isRead}),
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось изменить статус');
    }

    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return FeedbackItem.fromJson(data);
  }

  static Future<FeedbackListResponse> getList({
    FeedbackType? type,
    bool? isRead,
    int page = 1,
    int perPage = 20,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final query = <String, String>{
      'page': '$page',
      'per_page': '$perPage',
    };
    if (type != null) query['type'] = type.value;
    if (isRead != null) query['is_read'] = '$isRead';

    final uri = Uri.parse('${AuthService.baseUrl}/admin/feedback')
        .replace(queryParameters: query);

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось загрузить сообщения');
    }

    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return FeedbackListResponse.fromJson(data);
  }


  static Future<void> deleteFeedback(int feedbackId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.delete(
      Uri.parse('${AuthService.baseUrl}/admin/feedback/$feedbackId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось удалить сообщение');
    }
  }
}
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:lays_rating/models/user.dart';
import 'package:lays_rating/services/auth_service.dart';

class AdminService {
  AdminService._();
  static const Duration _timeout = Duration(seconds: 15);

  static Future<String> uploadNewsImage(String filePath) async {
    final token = await _getToken();

    final uri = Uri.parse('${AuthService.baseUrl}/admin/news/upload-image');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Не удалось загрузить картинку');
    }

    final data = jsonDecode(body) as Map<String, dynamic>;
    return data['image_path'] as String;
  }

  static Future<int> createNews({
    required String eventType,
    String? text,
    Map<String, dynamic>? extraData,
  }) async {
    final body = <String, dynamic>{
      'event_type': eventType,
      'text': text,
      if (extraData != null) 'extra_data': extraData,
    };

    final json = await _postJson('/admin/news', body: body);
    return (json as Map<String, dynamic>)['id'] as int;
  }

  static Future<void> deleteNews(int newsId) async {
    await _deleteJson('/admin/news/$newsId');
  }

  static Future<List<User>> getAdmins() async {
    final json = await _getJson('/admin/admins');
    return (json as List)
        .map((u) => User.fromJson(u as Map<String, dynamic>))
        .toList();
  }

  static Future<void> makeAdmin(int userId) async {
    await _postJson('/admin/admins/$userId');
  }

  static Future<void> removeAdmin(int userId) async {
    await _deleteJson('/admin/admins/$userId');
  }

  static Future<String> _getToken() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');
    return token;
  }

  static Future<dynamic> _getJson(String path) async {
    final token = await _getToken();
    final response = await http
        .get(
          Uri.parse('${AuthService.baseUrl}$path'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception(
        _extractError(response, 'Ошибка запроса: $path'),
      );
    }
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  static Future<dynamic> _postJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final token = await _getToken();

    final response = await http
        .post(
          Uri.parse('${AuthService.baseUrl}$path'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception(
        _extractError(response, 'Ошибка запроса: $path'),
      );
    }
    final text = utf8.decode(response.bodyBytes);
    if (text.isEmpty) return null;
    return jsonDecode(text);
  }

  static Future<void> _deleteJson(String path) async {
    final token = await _getToken();
    final response = await http
        .delete(
          Uri.parse('${AuthService.baseUrl}$path'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception(
        _extractError(response, 'Ошибка запроса: $path'),
      );
    }
  }

  static String _extractError(http.Response response, String fallback) {
    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is Map<String, dynamic>) {
        final detail = data['detail'];
        if (detail is String && detail.isNotEmpty) return detail;
      }
    } catch (_) {}
    return fallback;
  }
}
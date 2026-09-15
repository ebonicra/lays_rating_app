import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user.dart';
import 'auth_service.dart';


class AdminService {
  static Future<String> uploadNewsImage(String filePath) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final uri = Uri.parse('${AuthService.baseUrl}/admin/news/upload-image');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Не удалось загрузить картинку');
    }

    final data = jsonDecode(await response.stream.bytesToString());
    return data['image_path'];
  }

  static Future<int> createNews({
    required String eventType,
    String? text,
    Map<String, dynamic>? extraData,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final body = {
      'event_type': eventType,
      'text': text,
      if (extraData != null) 'extra_data': extraData,
    };

    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/admin/news'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['detail'] ?? 'Не удалось создать новость');
      } catch (_) {
        throw Exception('Не удалось создать новость');
      }
    }

    final data = jsonDecode(response.body);
    return data['id'];
  }

  static Future<void> deleteNews(int newsId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.delete(
      Uri.parse('${AuthService.baseUrl}/admin/news/$newsId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось удалить новость');
    }
  }


  static Future<List<User>> getAdmins() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/admin/admins'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось загрузить админов');
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    return data.map((u) => User.fromJson(u)).toList();
  }

  static Future<void> makeAdmin(int userId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/admin/admins/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['detail'] ?? 'Не удалось назначить админа');
      } catch (_) {
        throw Exception('Не удалось назначить админа');
      }
    }
  }

  static Future<void> removeAdmin(int userId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.delete(
      Uri.parse('${AuthService.baseUrl}/admin/admins/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['detail'] ?? 'Не удалось снять админа');
      } catch (_) {
        throw Exception('Не удалось снять админа');
      }
    }
  }
}
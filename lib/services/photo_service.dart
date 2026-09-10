// services/photo_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_photo.dart';
import 'auth_service.dart';


class PhotoService {
  
  /// Получить все фото пользователя
  static Future<PhotoListResponse> getUserPhotos(int userId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/photos/user/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return PhotoListResponse.fromJson(data);
    } else {
      throw Exception('Не удалось загрузить фото');
    }
  }

  /// Загрузить фото
  static Future<UserPhoto> uploadPhoto(String filePath) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final uri = Uri.parse('${AuthService.baseUrl}/photos/upload');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final response = await request.send();

    if (response.statusCode == 200) {
      final data = jsonDecode(await response.stream.bytesToString());
      return UserPhoto.fromJson(data);
    } else if (response.statusCode == 400) {
      final data = jsonDecode(await response.stream.bytesToString());
      throw Exception(data['detail'] ?? 'Ошибка загрузки');
    } else {
      throw Exception('Не удалось загрузить фото');
    }
  }

  /// Удалить фото
  static Future<void> deletePhoto(int photoId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.delete(
      Uri.parse('${AuthService.baseUrl}/photos/$photoId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось удалить фото');
    }
  }

  /// Поставить/убрать лайк
  static Future<PhotoReactionResponse> toggleLike(int photoId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/photos/$photoId/like'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return PhotoReactionResponse.fromJson(data);
    } else {
      throw Exception('Не удалось поставить лайк');
    }
  }

  /// Получить список тех, кто лайкнул
  static Future<PhotoLikersResponse> getLikers(int photoId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/photos/$photoId/likes'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return PhotoLikersResponse.fromJson(data);
    } else {
      throw Exception('Не удалось загрузить список');
    }
  }
}
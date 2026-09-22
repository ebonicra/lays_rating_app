import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:lays_rating/models/photo/photo.dart';
import 'package:lays_rating/models/photo/photo_likers.dart';
import 'package:lays_rating/models/photo/photo_list.dart';
import 'package:lays_rating/models/photo/photo_reaction.dart';
import 'package:lays_rating/services/auth_service.dart';

class PhotoService {
  PhotoService._();
  static const Duration _timeout = Duration(seconds: 15);

  static Future<PhotoList> getUserPhotos(int userId) async {
    final json = await _getJson('/photos/user/$userId');
    return PhotoList.fromJson(json as Map<String, dynamic>);
  }

  static Future<Photo> uploadPhoto(String filePath) async {
    final token = await _getToken();
    final uri = Uri.parse('${AuthService.baseUrl}/photos/upload');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      return Photo.fromJson(jsonDecode(body) as Map<String, dynamic>);
    }

    if (response.statusCode == 400) {
      final data = jsonDecode(body) as Map<String, dynamic>;
      throw Exception(data['detail'] ?? 'Ошибка загрузки');
    }
    throw Exception('Не удалось загрузить фото (${response.statusCode})');
  }

  static Future<void> deletePhoto(int photoId) async {
    await _deleteJson('/photos/$photoId');
  }

  static Future<PhotoReaction> toggleLike(int photoId) async {
    final json = await _postJson('/photos/$photoId/like');
    return PhotoReaction.fromJson(json as Map<String, dynamic>);
  }

  static Future<PhotoLikers> getLikers(int photoId) async {
    final json = await _getJson('/photos/$photoId/likes');
    return PhotoLikers.fromJson(json as Map<String, dynamic>);
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
      throw Exception('Ошибка запроса: $path (${response.statusCode})');
    }
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  static Future<dynamic> _postJson(String path) async {
    final token = await _getToken();

    final response = await http
        .post(
          Uri.parse('${AuthService.baseUrl}$path'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Ошибка запроса: $path (${response.statusCode})');
    }
    return jsonDecode(utf8.decode(response.bodyBytes));
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
      throw Exception('Ошибка запроса: $path (${response.statusCode})');
    }
  }
}
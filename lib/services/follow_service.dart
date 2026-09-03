import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import 'auth_service.dart';

class FollowService {
  
  /// Подписаться на пользователя
  static Future<void> followUser(int userId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/users/$userId/follow'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось подписаться: ${response.statusCode}');
    }
  }

  /// Отписаться от пользователя
  static Future<void> unfollowUser(int userId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.delete(
      Uri.parse('${AuthService.baseUrl}/users/$userId/follow'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось отписаться: ${response.statusCode}');
    }
  }

  /// Получить список подписчиков
  static Future<List<User>> getFollowers({
    required int userId,
    int page = 1,
    int perPage = 20,
  }) async {
    final token = await AuthService.getToken();

    final uri = Uri.parse('${AuthService.baseUrl}/users/$userId/followers').replace(
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return (data['users'] as List)
          .map((u) => User.fromJson(u))
          .toList();
    } else {
      throw Exception('Не удалось загрузить подписчиков');
    }
  }

  /// Получить список подписок
  static Future<List<User>> getFollowing({
    required int userId,
    int page = 1,
    int perPage = 20,
  }) async {
    final token = await AuthService.getToken();

    final uri = Uri.parse('${AuthService.baseUrl}/users/$userId/following').replace(
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return (data['users'] as List)
          .map((u) => User.fromJson(u))
          .toList();
    } else {
      throw Exception('Не удалось загрузить подписки');
    }
  }

  /// Проверить, подписан ли текущий пользователь на userId
  static Future<FollowStatus> checkFollowing(int userId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/users/$userId/is-following'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return FollowStatus.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Не удалось проверить подписку');
    }
  }


  static Future<List<User>> searchUsers(String query) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final uri = Uri.parse('${AuthService.baseUrl}/users/search').replace(
      queryParameters: {'q': query},
    );

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return (data as List).map((u) => User.fromJson(u)).toList();
    } else {
      throw Exception('Не удалось найти пользователей');
    }
  }


  /// Получить всех пользователей
  static Future<List<User>> getAllUsers() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/users/list'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return (data as List).map((u) => User.fromJson(u)).toList();
    } else {
      throw Exception('Не удалось загрузить пользователей');
    }
  }

}

/// Модель статуса подписки
class FollowStatus {
  final bool isFollowing;
  final int followersCount;
  final int followingCount;

  const FollowStatus({
    required this.isFollowing,
    required this.followersCount,
    required this.followingCount,
  });

  factory FollowStatus.fromJson(Map<String, dynamic> json) {
    return FollowStatus(
      isFollowing: json['is_following'] ?? false,
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
    );
  }
}
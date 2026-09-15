import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/follow_user.dart';
import '../models/user.dart';
import 'auth_service.dart';


class FollowService {
  static Future<void> followUser(int userId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/follows/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось подписаться: ${response.statusCode}');
    }
  }

  static Future<void> unfollowUser(int userId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.delete(
      Uri.parse('${AuthService.baseUrl}/follows/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось отписаться: ${response.statusCode}');
    }
  }

  static Future<List<FollowUser>> getFollowers({
    required int userId,
    int page = 1,
    int perPage = 20,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final uri = Uri.parse('${AuthService.baseUrl}/follows/$userId/followers')
        .replace(queryParameters: {
      'page': page.toString(),
      'per_page': perPage.toString(),
    });

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось загрузить подписчиков');
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    return (data['users'] as List)
        .map((u) => FollowUser.fromJson(u))
        .toList();
  }

  static Future<List<FollowUser>> getFollowing({
    required int userId,
    int page = 1,
    int perPage = 20,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final uri = Uri.parse('${AuthService.baseUrl}/follows/$userId/following')
        .replace(queryParameters: {
      'page': page.toString(),
      'per_page': perPage.toString(),
    });

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось загрузить подписки');
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    return (data['users'] as List)
        .map((u) => FollowUser.fromJson(u))
        .toList();
  }

  static Future<FollowStatus> checkFollowing(int userId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/follows/$userId/is-following'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось проверить подписку');
    }

    return FollowStatus.fromJson(jsonDecode(response.body));
  }

  static Future<List<User>> searchUsers(String query) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final uri = Uri.parse('${AuthService.baseUrl}/search/users')
        .replace(queryParameters: {'q': query});

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось найти пользователей');
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    return (data as List).map((u) => User.fromJson(u)).toList();
  }

  static Future<List<User>> getAllUsers() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/search/all'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось загрузить пользователей');
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    return (data as List).map((u) => User.fromJson(u)).toList();
  }
}



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
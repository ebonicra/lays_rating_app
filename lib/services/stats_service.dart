import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/follow_user.dart';
import '../models/stat_chip.dart';
import '../models/user_stats.dart';
import 'auth_service.dart';
import 'user_service.dart';

class StatsService {
  StatsService._();

  // ===== ПУБЛИЧНЫЕ МЕТОДЫ =====

  static Future<UserStats> getUserStats(int userId) async {
    final json = await _getJson('/stats/$userId');
    return UserStats.fromJson(json as Map<String, dynamic>);
  }

  static Future<UserStats> getMyStats() async {
    final userId = UserService.currentUser?.id;
    if (userId == null) throw Exception('User not loaded');
    return getUserStats(userId);
  }

  static Future<List<StatChip>> getFavoriteChips(int userId) =>
      _getList('/stats/$userId/favorites', StatChip.fromJson);

  static Future<List<StatChip>> getTriedChips(int userId) =>
      _getList('/stats/$userId/tried', StatChip.fromJson);

  static Future<List<StatChip>> getRatings(int userId) =>
      _getList('/stats/$userId/ratings', StatChip.fromJson);

  static Future<List<StatChip>> getCommentedChips(int userId) =>
      _getList('/stats/$userId/commented-chips', StatChip.fromJson);

  static Future<List<FollowUser>> getFriendsAverageRating(int userId) =>
      _getList('/stats/$userId/friends-average-rating', FollowUser.fromJson);

  // ===== ПРИВАТНЫЕ ХЕЛПЕРЫ =====

  /// GET-запрос, возвращает декодированный JSON (Map или List).
  static Future<dynamic> _getJson(String path) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No token');

    final response = await http
        .get(
          Uri.parse('${AuthService.baseUrl}$path'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Failed to load: $path (${response.statusCode})');
    }

    return jsonDecode(response.body);
  }

  /// GET-запрос, возвращает список моделей, декодированных через [fromJson].
  static Future<List<T>> _getList<T>(String path, T Function(Map<String, dynamic>) fromJson) async {
    final json = await _getJson(path);
    final list = json as List;
    return list
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
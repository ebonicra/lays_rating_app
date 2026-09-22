import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:lays_rating/models/stats/stats_chip.dart';
import 'package:lays_rating/models/stats/stats_follow.dart';
import 'package:lays_rating/models/stats/stats_user.dart';
import 'package:lays_rating/services/auth_service.dart';

class StatsService {
  StatsService._();
  static const Duration _timeout = Duration(seconds: 15);

  static Future<StatsUser> getUserStats(int userId) async {
    final json = await _getJson('/stats/$userId');
    return StatsUser.fromJson(json as Map<String, dynamic>);
  }

  static Future<List<StatsChip>> getFavoriteChips(int userId) =>
      _getList('/stats/$userId/favorites', StatsChip.fromJson);

  static Future<List<StatsChip>> getTriedChips(int userId) =>
      _getList('/stats/$userId/tried', StatsChip.fromJson);

  static Future<List<StatsChip>> getRatings(int userId) =>
      _getList(
        '/stats/$userId/ratings', 
        StatsChip.fromJson
      );

  static Future<List<StatsChip>> getCommentedChips(int userId) =>
      _getList(
        '/stats/$userId/commented-chips', 
        StatsChip.fromJson
      );

  static Future<List<StatsFollow>> getFollowers(int userId) =>
      _getList(
        '/follows/$userId/followers',
        StatsFollow.fromJson,
        arrayKey: 'users',
      );

  static Future<List<StatsFollow>> getFollowing(int userId) =>
      _getList(
        '/follows/$userId/following',
        StatsFollow.fromJson,
        arrayKey: 'users',
      );

  static Future<List<StatsFollow>> getFriendsAverageRating(int userId) =>
      _getList(
        '/stats/$userId/friends-average-rating',
        StatsFollow.fromJson,
      );

  static Future<dynamic> _getJson(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    var uri = Uri.parse('${AuthService.baseUrl}$path');
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }
    final response = await http
        .get(uri, headers: {'Authorization': 'Bearer $token'})
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Ошибка запроса: $path (${response.statusCode})');
    }
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  static Future<List<T>> _getList<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, String>? queryParams,
    String? arrayKey,
  }) async {
    final json = await _getJson(path, queryParams: queryParams);

    final List list;
    if (arrayKey != null) {
      list = (json as Map<String, dynamic>)[arrayKey] as List;
    } else {
      list = json as List;
    }

    return list
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
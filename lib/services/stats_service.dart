import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_stats.dart';
import '../models/stat_chip.dart';
import '../models/follow_user.dart';
import 'auth_service.dart';


class StatsService {
  
  /// Получить статистику текущего пользователя
  static Future<UserStats> getMyStats() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.get(
      Uri.parse("${AuthService.baseUrl}/users/me/stats"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load stats");
    }

    return UserStats.fromJson(jsonDecode(response.body));
  }

  /// Получить статистику другого пользователя
  static Future<UserStats> getUserStats(int userId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.get(
      Uri.parse("${AuthService.baseUrl}/users/$userId/stats"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load stats");
    }

    return UserStats.fromJson(jsonDecode(response.body));
  }

  /// Получить любимые чипсы пользователя
  static Future<List<StatChip>> getFavoriteChips(int userId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.get(
      Uri.parse("${AuthService.baseUrl}/users/$userId/favorites"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load favorites");
    }

    final data = jsonDecode(response.body) as List;
    return data.map((c) => StatChip.fromJson(c)).toList();
  }

  /// Получить чипсы, которые пользователь пробовал
  static Future<List<StatChip>> getTriedChips(int userId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.get(
      Uri.parse("${AuthService.baseUrl}/users/$userId/tried"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load tried chips");
    }

    final data = jsonDecode(response.body) as List;
    return data.map((c) => StatChip.fromJson(c)).toList();
  }

  static Future<List<StatChip>> getRatings(int userId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.get(
      Uri.parse("${AuthService.baseUrl}/users/$userId/ratings"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load ratings");
    }

    final data = jsonDecode(response.body) as List;
    return data.map((c) => StatChip.fromJson(c)).toList();
  }


  static Future<List<FollowUser>> getFollowing(int userId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.get(
      Uri.parse("${AuthService.baseUrl}/users/$userId/following"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load following");
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['users'] as List)
        .map((u) => FollowUser.fromJson(u))
        .toList();
  }

  static Future<List<FollowUser>> getFollowers(int userId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.get(
      Uri.parse("${AuthService.baseUrl}/users/$userId/followers"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load followers");
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['users'] as List)
        .map((u) => FollowUser.fromJson(u))
        .toList();
  }


  static Future<List<FollowUser>> getFriendsAverageRating(int userId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.get(
      Uri.parse("${AuthService.baseUrl}/users/$userId/friends-average-rating"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load friends rating");
    }

    final data = jsonDecode(response.body) as List;
    return data.map((f) => FollowUser.fromJson(f)).toList();
  }


  static Future<List<StatChip>> getCommentedChips(int userId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.get(
      Uri.parse("${AuthService.baseUrl}/users/$userId/commented-chips"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load commented chips");
    }

    final data = jsonDecode(response.body) as List;
    return data.map((c) => StatChip.fromJson(c)).toList();
  }
}
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/follow_user.dart';
import '../models/stat_chip.dart';
import '../models/user_stats.dart';
import 'auth_service.dart';
import 'user_service.dart';


class StatsService {
  static Future<UserStats> getUserStats(int userId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.get(
      Uri.parse("${AuthService.baseUrl}/stats/$userId"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load stats");
    }
    return UserStats.fromJson(jsonDecode(response.body));
  }

  static Future<UserStats> getMyStats() async {
    final userId = UserService.currentUser?.id;
    if (userId == null) throw Exception("User not loaded");
    return getUserStats(userId);
  }

  static Future<List<StatChip>> getFavoriteChips(int userId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.get(
      Uri.parse("${AuthService.baseUrl}/stats/$userId/favorites"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load favorites");
    }

    final data = jsonDecode(response.body) as List;
    return data.map((c) => StatChip.fromJson(c)).toList();
  }

  static Future<List<StatChip>> getTriedChips(int userId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.get(
      Uri.parse("${AuthService.baseUrl}/stats/$userId/tried"),
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
      Uri.parse("${AuthService.baseUrl}/stats/$userId/ratings"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load ratings");
    }

    final data = jsonDecode(response.body) as List;
    return data.map((c) => StatChip.fromJson(c)).toList();
  }

  static Future<List<FollowUser>> getFriendsAverageRating(int userId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.get(
      Uri.parse("${AuthService.baseUrl}/stats/$userId/friends-average-rating"),
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
      Uri.parse("${AuthService.baseUrl}/stats/$userId/commented-chips"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load commented chips");
    }

    final data = jsonDecode(response.body) as List;
    return data.map((c) => StatChip.fromJson(c)).toList();
  }
}
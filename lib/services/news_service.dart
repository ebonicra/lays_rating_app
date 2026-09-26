import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/news_item.dart';
import 'auth_service.dart';
import 'package:lays_rating/widgets/common/reactions_sheet.dart';

class NewsService {
  static Future<List<NewsItem>> getFeed() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.get(
      Uri.parse("${AuthService.baseUrl}/news/feed"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load feed");
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    return data.map((item) => NewsItem.fromJson(item)).toList();
  }

  static Future<void> vote(int newsId, int optionIndex) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.post(
      Uri.parse(
        "${AuthService.baseUrl}/news/$newsId/vote?option_index=$optionIndex",
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200) {
      final data = _decodeBody(response);
      throw Exception(data['detail'] ?? 'Не удалось проголосовать');
    }
  }

  static Future<void> removeVote(int newsId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.delete(
      Uri.parse("${AuthService.baseUrl}/news/$newsId/vote"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      final data = _decodeBody(response);
      throw Exception(data['detail'] ?? 'Не удалось отменить голос');
    }
  }

  /// Поставить/сменить/снять реакцию на новость.
  /// Бэкенд сам решает: та же реакция → снять, другая → поменять, нет → создать.
  static Future<NewsReactionResult> setNewsReaction(
    int newsId, {
    required bool isLike,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.post(
      Uri.parse("${AuthService.baseUrl}/news/$newsId/reaction"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"is_like": isLike}),
    );

    if (response.statusCode != 200) {
      final data = _decodeBody(response);
      throw Exception(data['detail'] ?? 'Не удалось поставить реакцию');
    }

    return NewsReactionResult.fromJson(_decodeBody(response));
  }

  /// Список тех, кто лайкнул/дизлайкнул новость.
  static Future<NewsReactionsList> getNewsReactions(int newsId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.get(
      Uri.parse("${AuthService.baseUrl}/news/$newsId/reactions"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      final data = _decodeBody(response);
      throw Exception(data['detail'] ?? 'Не удалось загрузить реакции');
    }

    return NewsReactionsList.fromJson(_decodeBody(response));
  }

  static Map<String, dynamic> _decodeBody(http.Response response) {
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }
}

// ===== МОДЕЛИ ОТВЕТОВ =====

/// Ответ POST /news/{id}/reaction
class NewsReactionResult {
  const NewsReactionResult({
    required this.likesCount,
    required this.dislikesCount,
    required this.myReaction,
  });

  final int likesCount;
  final int dislikesCount;
  final bool? myReaction;

  factory NewsReactionResult.fromJson(Map<String, dynamic> json) {
    return NewsReactionResult(
      likesCount: json['news_likes_count'] as int? ?? 0,
      dislikesCount: json['news_dislikes_count'] as int? ?? 0,
      myReaction: json['my_news_reaction'] as bool?,
    );
  }
}

/// Краткая инфа о пользователе, поставившем реакцию
class NewsReactionUser {
  const NewsReactionUser({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
  });

  final int id;
  final String username;
  final String? displayName;
  final String? avatarUrl;

  factory NewsReactionUser.fromJson(Map<String, dynamic> json) {
    return NewsReactionUser(
      id: json['id'] as int,
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

/// Ответ GET /news/{id}/reactions
class NewsReactionsList {
  const NewsReactionsList({
    required this.likes,
    required this.dislikes,
  });

  final List<NewsReactionUser> likes;
  final List<NewsReactionUser> dislikes;

  factory NewsReactionsList.fromJson(Map<String, dynamic> json) {
    return NewsReactionsList(
      likes: (json['likes'] as List)
          .map((e) => NewsReactionUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      dislikes: (json['dislikes'] as List)
          .map((e) => NewsReactionUser.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}


extension NewsReactionUserMapper on NewsReactionUser {
  ReactionUser toReactionUser() => ReactionUser(
    id: id,
    username: username,
    displayName: displayName,
    avatarUrl: avatarUrl,
  );
}
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chip_comment.dart';
import 'package:lays_rating/models/comment_reaction.dart';
import 'package:lays_rating/widgets/common/reactions_sheet.dart';
import 'auth_service.dart';


class CommentsService {
  static const String baseUrl = AuthService.baseUrl;

  static Future<ChipCommentListResponse> getComments({
    required int chipId,
    int page = 1,
    int perPage = 20,
    String sortBy = 'newest',
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final uri = Uri.parse('$baseUrl/comments').replace(
      queryParameters: {
        'chip_id': chipId.toString(),
        'page': page.toString(),
        'per_page': perPage.toString(),
        'sort_by': sortBy,
      },
    );

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось загрузить комментарии: ${response.statusCode}');
    }

    final data = json.decode(utf8.decode(response.bodyBytes));
    return ChipCommentListResponse.fromJson(data);
  }

  static Future<ChipCommentResponse> createComment({
    required int chipId,
    required String text,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.post(
      Uri.parse('$baseUrl/comments'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'chip_id': chipId,
        'text': text,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось создать комментарий: ${response.statusCode}');
    }

    final data = json.decode(utf8.decode(response.bodyBytes));
    return ChipCommentResponse.fromJson(data);
  }

  static Future<ChipCommentResponse> updateComment({
    required int commentId,
    required String text,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.put(
      Uri.parse('$baseUrl/comments/$commentId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'text': text}),
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось обновить комментарий: ${response.statusCode}');
    }

    final data = json.decode(utf8.decode(response.bodyBytes));
    return ChipCommentResponse.fromJson(data);
  }

  static Future<void> deleteComment({
    required int commentId,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.delete(
      Uri.parse('$baseUrl/comments/$commentId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось удалить комментарий: ${response.statusCode}');
    }
  }

  static Future<CommentReactionResponse> setReaction({
    required int commentId,
    required bool isLike,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.post(
      Uri.parse('$baseUrl/comments/$commentId/reaction'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'is_like': isLike}),
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось поставить реакцию: ${response.statusCode}');
    }

    final data = json.decode(utf8.decode(response.bodyBytes));
    return CommentReactionResponse.fromJson(data);
  }

  static Future<void> removeReaction({
    required int commentId,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final response = await http.delete(
      Uri.parse('$baseUrl/comments/$commentId/reaction'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось удалить реакцию: ${response.statusCode}');
    }
  }


  static Future<CommentReactionsList> getCommentReactions(int commentId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("No token");

    final response = await http.get(
      Uri.parse("${AuthService.baseUrl}/comments/$commentId/reactions"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(data['detail'] ?? 'Не удалось загрузить реакции');
    }

    return CommentReactionsList.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }
}


extension CommentReactionUserMapper on CommentReactionUser {
  ReactionUser toReactionUser() => ReactionUser(
    id: id,
    username: username,
    displayName: displayName,
    avatarUrl: avatarUrl,
  );
}
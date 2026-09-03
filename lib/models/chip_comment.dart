// models/chip_comment.dart

class CommentAuthor {
  final int id;
  final String username;
  final String? avatarUrl;

  const CommentAuthor({
    required this.id,
    required this.username,
    this.avatarUrl,
  });

  factory CommentAuthor.fromJson(Map<String, dynamic> json) {
    return CommentAuthor(
      id: json['id'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
    );
  }
}

class CommentReactionResponse {
  final bool? isLiked; // null - нет реакции, true - лайк, false - дизлайк
  const CommentReactionResponse({this.isLiked});

  factory CommentReactionResponse.fromJson(Map<String, dynamic> json) {
    return CommentReactionResponse(
      isLiked: json['is_liked'],
    );
  }
}

class ChipCommentResponse {
  final int id;
  final CommentAuthor user;
  final String text;
  final int? rating;
  final int likesCount;
  final int dislikesCount;
  final CommentReactionResponse? userReaction;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChipCommentResponse({
    required this.id,
    required this.user,
    required this.text,
    this.rating,
    required this.likesCount,
    required this.dislikesCount,
    this.userReaction,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChipCommentResponse.fromJson(Map<String, dynamic> json) {
    return ChipCommentResponse(
      id: json['id'],
      user: CommentAuthor.fromJson(json['user']),
      text: json['text'],
      rating: json['rating'],
      likesCount: json['likes_count'] ?? 0,
      dislikesCount: json['dislikes_count'] ?? 0,
      userReaction: json['user_reaction'] != null
          ? CommentReactionResponse.fromJson(json['user_reaction'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  ChipCommentResponse copyWith({
    int? likesCount,
    int? dislikesCount,
    CommentReactionResponse? userReaction,
  }) {
    return ChipCommentResponse(
      id: id,
      user: user,
      text: text,
      rating: rating,
      likesCount: likesCount ?? this.likesCount,
      dislikesCount: dislikesCount ?? this.dislikesCount,
      userReaction: userReaction ?? this.userReaction,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class ChipCommentListResponse {
  final List<ChipCommentResponse> comments;
  final int totalCount;

  const ChipCommentListResponse({
    required this.comments,
    required this.totalCount,
  });

  factory ChipCommentListResponse.fromJson(Map<String, dynamic> json) {
    return ChipCommentListResponse(
      comments: (json['comments'] as List)
          .map((c) => ChipCommentResponse.fromJson(c))
          .toList(),
      totalCount: json['total_count'],
    );
  }
}
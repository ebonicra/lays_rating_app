class CommentReactionUser {
  const CommentReactionUser({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
  });

  final int id;
  final String username;
  final String? displayName;
  final String? avatarUrl;

  factory CommentReactionUser.fromJson(Map<String, dynamic> json) {
    return CommentReactionUser(
      id: json['id'] as int,
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class CommentReactionsList {
  const CommentReactionsList({required this.likes, required this.dislikes});

  final List<CommentReactionUser> likes;
  final List<CommentReactionUser> dislikes;

  factory CommentReactionsList.fromJson(Map<String, dynamic> json) {
    return CommentReactionsList(
      likes: (json['likes'] as List)
          .map((e) => CommentReactionUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      dislikes: (json['dislikes'] as List)
          .map((e) => CommentReactionUser.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
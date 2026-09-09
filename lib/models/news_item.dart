class NewsItem {
  final int id;
  final String eventType;
  final String? text;
  final DateTime createdAt;
  final NewsUser? user;
  final NewsChip? chip;
  final int? userRating;
  final Map<String, dynamic>? extraData;
  final int? commentId;
  final int? likesCount;
  final int? dislikesCount;
  final bool? myReaction;

  const NewsItem({
    required this.id,
    required this.eventType,
    this.text,
    required this.createdAt,
    this.user,
    this.chip,
    this.userRating,
    this.extraData,
    this.commentId,
    this.likesCount,
    this.dislikesCount,
    this.myReaction,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'],
      eventType: json['event_type'],
      text: json['text'],
      createdAt: DateTime.parse(json['created_at']),
      user: json['user'] != null ? NewsUser.fromJson(json['user']) : null,
      chip: json['chip'] != null ? NewsChip.fromJson(json['chip']) : null,
      userRating: json['user_rating'],
      extraData: json['extra_data'] != null
          ? Map<String, dynamic>.from(json['extra_data'])
          : null,
      commentId: json['comment_id'],
      likesCount: json['likes_count'],
      dislikesCount: json['dislikes_count'],
      myReaction: json['my_reaction'],
    );
  }
}

class NewsUser {
  final int id;
  final String username;
  final String displayName;
  final String? avatarUrl;

  const NewsUser({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
  });

  factory NewsUser.fromJson(Map<String, dynamic> json) {
    return NewsUser(
      id: json['id'],
      username: json['username'],
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
    );
  }
}

class NewsChip {
  final int id;
  final String name;
  final String imagePath;

  const NewsChip({
    required this.id,
    required this.name,
    required this.imagePath,
  });

  factory NewsChip.fromJson(Map<String, dynamic> json) {
    return NewsChip(
      id: json['id'],
      name: json['name'],
      imagePath: json['image_path'] ?? '',
    );
  }
}
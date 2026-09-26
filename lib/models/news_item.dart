import 'package:lays_rating/models/poll.dart';

class NewsItem {
  final int id;
  final String eventType;
  final String? text;
  final DateTime createdAt;
  final NewsUser? user;
  final NewsChip? chip;
  final int? userRating;
  final Map<String, dynamic>? extraData;
  final PollData? poll;

  // Комментарий (friend_comment)
  final int? commentId;
  final int commentLikesCount;
  final int commentDislikesCount;
  final bool? myCommentReaction;

  // Новость (admin_post, rumor, poll)
  final int newsLikesCount;
  final int newsDislikesCount;
  final bool? myNewsReaction;

  const NewsItem({
    required this.id,
    required this.eventType,
    this.text,
    required this.createdAt,
    this.user,
    this.chip,
    this.userRating,
    this.extraData,
    this.poll,
    this.commentId,
    this.commentLikesCount = 0,
    this.commentDislikesCount = 0,
    this.myCommentReaction,
    this.newsLikesCount = 0,
    this.newsDislikesCount = 0,
    this.myNewsReaction,
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
      poll: json['poll'] != null ? PollData.fromJson(json['poll']) : null,
      commentId: json['comment_id'],
      commentLikesCount: json['comment_likes_count'] as int? ?? 0,
      commentDislikesCount: json['comment_dislikes_count'] as int? ?? 0,
      myCommentReaction: json['my_comment_reaction'] as bool?,
      newsLikesCount: json['news_likes_count'] as int? ?? 0,
      newsDislikesCount: json['news_dislikes_count'] as int? ?? 0,
      myNewsReaction: json['my_news_reaction'] as bool?,
    );
  }

  NewsItem copyWith({
    PollData? poll,
    int? newsLikesCount,
    int? newsDislikesCount,
    bool? myNewsReaction,
    bool clearNewsReaction = false,
  }) {
    return NewsItem(
      id: id,
      eventType: eventType,
      text: text,
      createdAt: createdAt,
      user: user,
      chip: chip,
      userRating: userRating,
      extraData: extraData,
      poll: poll ?? this.poll,
      commentId: commentId,
      commentLikesCount: commentLikesCount,
      commentDislikesCount: commentDislikesCount,
      myCommentReaction: myCommentReaction,
      newsLikesCount: newsLikesCount ?? this.newsLikesCount,
      newsDislikesCount: newsDislikesCount ?? this.newsDislikesCount,
      myNewsReaction:
          clearNewsReaction ? null : (myNewsReaction ?? this.myNewsReaction),
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
import 'feedback.dart';

class FeedbackUser {
  const FeedbackUser({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
  });

  final int id;
  final String username;
  final String? displayName;
  final String? avatarUrl;

  factory FeedbackUser.fromJson(Map<String, dynamic> json) {
    return FeedbackUser(
      id: json['id'] as int,
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class FeedbackItem {
  const FeedbackItem({
    required this.id,
    required this.user,
    required this.type,
    required this.title,
    required this.text,
    required this.imagePaths,
    required this.isRead,
    required this.createdAt,
  });

  final int id;
  final FeedbackUser user;
  final FeedbackType type;
  final String title;
  final String text;
  final List<String> imagePaths;
  final bool isRead;
  final DateTime createdAt;

  factory FeedbackItem.fromJson(Map<String, dynamic> json) {
    return FeedbackItem(
      id: json['id'] as int,
      user: FeedbackUser.fromJson(json['user'] as Map<String, dynamic>),
      type: FeedbackType.fromValue(json['type'] as String),
      title: json['title'] as String? ?? '',
      text: json['text'] as String? ?? '',
      imagePaths: (json['image_paths'] as List? ?? [])
          .map((e) => e as String)
          .toList(),
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  FeedbackItem copyWith({bool? isRead}) {
    return FeedbackItem(
      id: id,
      user: user,
      type: type,
      title: title,
      text: text,
      imagePaths: imagePaths,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}

class FeedbackListResponse {
  const FeedbackListResponse({
    required this.items,
    required this.totalCount,
    required this.unreadCount,
  });

  final List<FeedbackItem> items;
  final int totalCount;
  final int unreadCount;

  factory FeedbackListResponse.fromJson(Map<String, dynamic> json) {
    return FeedbackListResponse(
      items: (json['items'] as List)
          .map((e) => FeedbackItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['total_count'] as int? ?? 0,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }
}
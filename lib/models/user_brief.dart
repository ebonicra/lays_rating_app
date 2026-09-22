import 'package:lays_rating/models/user.dart';

/// Краткая информация о пользователе
class UserBrief {
  const UserBrief({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
  });

  final int id;
  final String username;
  final String displayName;
  final String? avatarUrl;

  factory UserBrief.fromJson(Map<String, dynamic> json) {
    return UserBrief(
      id: json['id'] as int,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  factory UserBrief.fromUser(User user) {
    return UserBrief(
      id: user.id,
      username: user.username,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
    );
  }
}
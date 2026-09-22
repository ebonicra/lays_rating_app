import 'package:lays_rating/models/user.dart';

// Пользователь в контексте статистики подписок
class StatsFollow {
  const StatsFollow({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.averageRating,
  });

  final int id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final double? averageRating;

  factory StatsFollow.fromJson(Map<String, dynamic> json) {
    return StatsFollow(
      id: json['id'] as int,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
    );
  }

  factory StatsFollow.fromUser(User user, {double? averageRating}) {
    return StatsFollow(
      id: user.id,
      username: user.username,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      averageRating: averageRating,
    );
  }
}
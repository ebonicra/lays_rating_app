import 'package:lays_rating/models/user_brief.dart';

/// Оценка чипса конкретным пользователем.
class ChipRatingWithUser {
  const ChipRatingWithUser({
    required this.user,
    required this.rating,
    required this.createdAt,
  });

  final UserBrief user;
  final int rating;
  final DateTime createdAt;

  factory ChipRatingWithUser.fromJson(Map<String, dynamic> json) {
    return ChipRatingWithUser(
      user: UserBrief.fromJson(json['user'] as Map<String, dynamic>),
      rating: (json['rating'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
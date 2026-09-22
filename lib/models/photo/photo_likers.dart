import 'package:lays_rating/models/photo/photo_author.dart';

/// Ответ API со списком тех, кто лайкнул фото.
class PhotoLikers {
  const PhotoLikers({
    required this.users,
    required this.totalCount,
  });

  final List<PhotoAuthor> users;
  final int totalCount;

  factory PhotoLikers.fromJson(Map<String, dynamic> json) {
    return PhotoLikers(
      users: (json['users'] as List)
          .map((u) => PhotoAuthor.fromJson(u as Map<String, dynamic>))
          .toList(),
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
    );
  }
}
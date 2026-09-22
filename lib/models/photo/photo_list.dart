import 'package:lays_rating/models/photo/photo.dart';

/// Ответ API со списком фото пользователя.
class PhotoList {
  const PhotoList({
    required this.photos,
    required this.totalCount,
  });

  final List<Photo> photos;
  final int totalCount;

  factory PhotoList.fromJson(Map<String, dynamic> json) {
    return PhotoList(
      photos: (json['photos'] as List)
          .map((p) => Photo.fromJson(p as Map<String, dynamic>))
          .toList(),
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
    );
  }
}
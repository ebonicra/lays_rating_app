import 'package:lays_rating/models/photo/photo_author.dart';

/// Одно фото пользователя.
class Photo {
  const Photo({
    required this.id,
    required this.user,
    required this.imagePath,
    required this.likesCount,
    required this.isLiked,
    required this.createdAt,
  });

  final int id;
  final PhotoAuthor user;
  final String imagePath;
  final int likesCount;
  final bool isLiked;
  final DateTime createdAt;

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as int,
      user: PhotoAuthor.fromJson(json['user'] as Map<String, dynamic>),
      imagePath: json['image_path'] as String? ?? '',
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Photo copyWith({
    int? likesCount,
    bool? isLiked,
  }) {
    return Photo(
      id: id,
      user: user,
      imagePath: imagePath,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
    );
  }
}
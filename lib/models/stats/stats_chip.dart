// Чипс со статистикой — общей и личной (относительно пользователя)
class StatsChip {
  const StatsChip({
    required this.id,
    required this.name,
    required this.averageRating,
    required this.ratingCount,
    required this.favoriteCount,
    required this.triedCount,
    required this.imagePath,
    this.myRating,
    this.myCommentsCount = 0,
    this.reactionsCount = 0,
  });

  final int id;
  final String name;
  final double averageRating;
  final int ratingCount;
  final int favoriteCount;
  final int triedCount;
  final String imagePath;
  final int? myRating;
  final int myCommentsCount;
  final int reactionsCount;

  factory StatsChip.fromJson(Map<String, dynamic> json) {
    return StatsChip(
      id: json['id'] as int,
      name: json['name'] as String,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
      favoriteCount: (json['favorite_count'] as num?)?.toInt() ?? 0,
      triedCount: (json['tried_count'] as num?)?.toInt() ?? 0,
      imagePath: json['image_path'] as String? ?? '',
      myRating: (json['my_rating'] as num?)?.toInt(),
      myCommentsCount: (json['my_comments_count'] as num?)?.toInt() ?? 0,
      reactionsCount: (json['reactions_count'] as num?)?.toInt() ?? 0,
    );
  }
}
class StatChip {
  final int id;
  final String name;
  final double averageRating;
  final int ratingCount;
  final int favoriteCount;
  final int triedCount;
  final int? myRating; // ← добавили
  final String imagePath;
  final int myCommentsCount; // ← добавили
  final int reactionsCount; 

  const StatChip({
    required this.id,
    required this.name,
    required this.averageRating,
    required this.ratingCount,
    required this.favoriteCount,
    required this.triedCount,
    this.myRating,
    this.myCommentsCount = 0, // ← по умолчанию 0
    this.reactionsCount = 0,
    required this.imagePath,
  });

  factory StatChip.fromJson(Map<String, dynamic> json) {
    return StatChip(
      id: json['id'],
      name: json['name'],
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      ratingCount: json['rating_count'] ?? 0,
      favoriteCount: json['favorite_count'] ?? 0,
      triedCount: json['tried_count'] ?? 0,
      myRating: json['my_rating'],
      myCommentsCount: json['my_comments_count'] ?? 0,
      reactionsCount: json['reactions_count'] ?? 0,
      imagePath: json['image_path'] ?? '',
    );
  }
}
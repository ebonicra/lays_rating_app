class UserStats {
  final int ratingsCount;
  final int favoritesCount;
  final int triedCount;
  final int commentsCount;
  final double averageRating;
  final int followersCount;
  final int followingCount;  

  const UserStats({
    required this.ratingsCount,
    required this.favoritesCount,
    required this.triedCount,
    required this.commentsCount,
    required this.averageRating,
    required this.followersCount, 
    required this.followingCount,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      ratingsCount: json['ratings_count'] ?? 0,
      favoritesCount: json['favorites_count'] ?? 0,
      triedCount: json['tried_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
    );
  }
}
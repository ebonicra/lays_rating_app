class StatsUser {
  const StatsUser({
    required this.ratingsCount,
    required this.favoritesCount,
    required this.triedCount,
    required this.commentsCount,
    required this.averageRating,
    required this.followersCount,
    required this.followingCount,
  });

  final int ratingsCount;
  final int favoritesCount;
  final int triedCount;
  final int commentsCount;
  final double averageRating;
  final int followersCount;
  final int followingCount;

  factory StatsUser.fromJson(Map<String, dynamic> json) {
    return StatsUser(
      ratingsCount: (json['ratings_count'] as num?)?.toInt() ?? 0,
      favoritesCount: (json['favorites_count'] as num?)?.toInt() ?? 0,
      triedCount: (json['tried_count'] as num?)?.toInt() ?? 0,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
      followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
    );
  }
}
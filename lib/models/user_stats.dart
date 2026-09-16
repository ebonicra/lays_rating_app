class UserStats {
  const UserStats({
    required this.ratingsCount,
    required this.favoritesCount,
    required this.triedCount,
    required this.commentsCount,
    required this.averageRating,
    required this.followersCount,
    required this.followingCount,
  });

  /// Сколько всего оценок поставил пользователь.
  final int ratingsCount;

  /// Сколько чипсов пользователь добавил в любимчики.
  final int favoritesCount;

  /// Сколько чипсов пользователь попробовал.
  final int triedCount;

  /// Сколько комментариев написал пользователь.
  final int commentsCount;

  /// Средняя оценка, которую ставит пользователь.
  final double averageRating;

  /// Сколько у пользователя подписчиков.
  final int followersCount;

  /// На скольких пользователей подписан.
  final int followingCount;

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
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
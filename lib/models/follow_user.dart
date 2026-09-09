class FollowUser {
  final int id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final double? averageRating; // ← добавили

  const FollowUser({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.averageRating,
  });

  factory FollowUser.fromJson(Map<String, dynamic> json) {
    return FollowUser(
      id: json['id'],
      username: json['username'],
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
      averageRating: json['average_rating'] != null
          ? (json['average_rating'] as num).toDouble()
          : null,
    );
  }
}
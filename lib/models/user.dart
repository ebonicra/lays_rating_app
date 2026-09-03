class User {
  final int id;
  final String username;
  final String displayName;
  final bool isAdmin;
  final String? avatarUrl;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    required this.displayName,
    required this.isAdmin,
    this.avatarUrl,
    required this.createdAt,
  });


  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      username: json["username"],
      displayName: json["display_name"],
      isAdmin: json['is_admin'] ?? false,
      avatarUrl: json['avatar_url'],
      createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : DateTime.now(), // ← добавили
    );
  }
}

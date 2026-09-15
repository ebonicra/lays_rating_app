class User {
  final int id;
  final String username;
  final String displayName;
  final String role;
  final String? avatarUrl;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin' || role == 'super_admin';
  bool get isSuperAdmin => role == 'super_admin';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      username: json["username"],
      displayName: json["display_name"],
      role: json["role"] ?? "user",
      avatarUrl: json["avatar_url"],
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : DateTime.now(),
    );
  }
}
/// Автор фото (краткая информация о пользователе).
class PhotoAuthor {
  const PhotoAuthor({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
  });

  final int id;
  final String username;
  final String displayName;
  final String? avatarUrl;

  factory PhotoAuthor.fromJson(Map<String, dynamic> json) {
    return PhotoAuthor(
      id: json['id'] as int,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
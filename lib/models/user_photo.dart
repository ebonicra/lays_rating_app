// models/user_photo.dart

class UserPhoto {
  final int id;
  final PhotoAuthor user;
  final String imagePath;
  final int likesCount;
  final bool isLiked;
  final DateTime createdAt;

  const UserPhoto({
    required this.id,
    required this.user,
    required this.imagePath,
    required this.likesCount,
    required this.isLiked,
    required this.createdAt,
  });

  factory UserPhoto.fromJson(Map<String, dynamic> json) {
    return UserPhoto(
      id: json['id'],
      user: PhotoAuthor.fromJson(json['user']),
      imagePath: json['image_path'] ?? '',
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  UserPhoto copyWith({
    int? likesCount,
    bool? isLiked,
  }) {
    return UserPhoto(
      id: id,
      user: user,
      imagePath: imagePath,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
    );
  }
}

class PhotoAuthor {
  final int id;
  final String username;
  final String displayName;
  final String? avatarUrl;

  const PhotoAuthor({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
  });

  factory PhotoAuthor.fromJson(Map<String, dynamic> json) {
    return PhotoAuthor(
      id: json['id'],
      username: json['username'],
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
    );
  }
}

class PhotoListResponse {
  final List<UserPhoto> photos;
  final int totalCount;

  const PhotoListResponse({
    required this.photos,
    required this.totalCount,
  });

  factory PhotoListResponse.fromJson(Map<String, dynamic> json) {
    return PhotoListResponse(
      photos: (json['photos'] as List)
          .map((p) => UserPhoto.fromJson(p))
          .toList(),
      totalCount: json['total_count'] ?? 0,
    );
  }
}

class PhotoReactionResponse {
  final bool isLiked;
  final int likesCount;

  const PhotoReactionResponse({
    required this.isLiked,
    required this.likesCount,
  });

  factory PhotoReactionResponse.fromJson(Map<String, dynamic> json) {
    return PhotoReactionResponse(
      isLiked: json['is_liked'] ?? false,
      likesCount: json['likes_count'] ?? 0,
    );
  }
}

class PhotoLikersResponse {
  final List<PhotoAuthor> users;
  final int totalCount;

  const PhotoLikersResponse({
    required this.users,
    required this.totalCount,
  });

  factory PhotoLikersResponse.fromJson(Map<String, dynamic> json) {
    return PhotoLikersResponse(
      users: (json['users'] as List)
          .map((u) => PhotoAuthor.fromJson(u))
          .toList(),
      totalCount: json['total_count'] ?? 0,
    );
  }
}
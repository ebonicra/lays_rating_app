/// Ответ API после лайка / снятия лайка.
class PhotoReaction {
  const PhotoReaction({
    required this.isLiked,
    required this.likesCount,
  });

  final bool isLiked;
  final int likesCount;

  factory PhotoReaction.fromJson(Map<String, dynamic> json) {
    return PhotoReaction(
      isLiked: json['is_liked'] as bool? ?? false,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
    );
  }
}
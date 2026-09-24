import 'package:lays_rating/models/chip_type.dart';

class ChipRating {
  const ChipRating({
    required this.average,
    required this.count,
    this.userRating,
  });

  final double average;
  final int count;
  final int? userRating;

  factory ChipRating.fromJson(Map<String, dynamic> json) {
    return ChipRating(
      average: (json['average'] as num?)?.toDouble() ?? 0.0,
      count: (json['count'] as num?)?.toInt() ?? 0,
      userRating: (json['user_rating'] as num?)?.toInt(),
    );
  }

  ChipRating copyWith({
    double? average,
    int? count,
    int? userRating,
  }) {
    return ChipRating(
      average: average ?? this.average,
      count: count ?? this.count,
      userRating: userRating ?? this.userRating,
    );
  }
}

class LaysChip {
  const LaysChip({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.imagePath,
    required this.available,
    required this.rating,
    required this.collection,
    required this.country,
    required this.releaseYear,
    required this.commentCount,
    required this.isFavorite,
    required this.isTried,
  });

  final int id;
  final String name;
  final ChipType category;
  final String description;
  final String imagePath;
  final bool available;
  final ChipRating rating;
  final String collection;
  final String country;
  final int releaseYear;
  final int commentCount;
  final bool isFavorite;
  final bool isTried;

  factory LaysChip.fromJson(Map<String, dynamic> json) {
    return LaysChip(
      id: json['id'] as int,
      name: json['name'] as String,
      category: ChipType.values.firstWhere(
        (e) => e.value == json['category'],
        orElse: () => ChipType.classic,
      ),
      description: json['description'] as String,
      imagePath: json['image_path'] as String,
      available: json['available'] as bool? ?? false,
      collection: json['collection'] as String,
      country: json['country'] as String,
      releaseYear: (json['release_year'] as num?)?.toInt() ?? 0,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      rating: ChipRating.fromJson(
        json['rating'] as Map<String, dynamic>,
      ),
      isFavorite: json['is_favorite'] as bool? ?? false,
      isTried: json['is_tried'] as bool? ?? false,
    );
  }

  LaysChip copyWith({
    int? id,
    String? name,
    ChipType? category,
    String? description,
    String? imagePath,
    bool? available,
    ChipRating? rating,
    String? collection,
    String? country,
    int? releaseYear,
    int? commentCount,
    bool? isFavorite,
    bool? isTried,
  }) {
    return LaysChip(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      available: available ?? this.available,
      rating: rating ?? this.rating,
      collection: collection ?? this.collection,
      country: country ?? this.country,
      releaseYear: releaseYear ?? this.releaseYear,
      commentCount: commentCount ?? this.commentCount,
      isFavorite: isFavorite ?? this.isFavorite,
      isTried: isTried ?? this.isTried,
    );
  }
}
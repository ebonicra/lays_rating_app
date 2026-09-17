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
    );
  }

  LaysChip copyWith({ChipRating? rating}) {
    return LaysChip(
      id: id,
      name: name,
      category: category,
      description: description,
      imagePath: imagePath,
      available: available,
      collection: collection,
      country: country,
      releaseYear: releaseYear,
      commentCount: commentCount,
      rating: rating ?? this.rating,
    );
  }
}
import 'dart:ffi';

enum ChipCategory {
  stix,
  classic,
  maxx,
  stax,
  baked,
  ridged,
}


extension ChipCategoryExtension on ChipCategory {
  String get title {
    switch (this) {
      case ChipCategory.classic:
        return "Классические";

      case ChipCategory.maxx:
        return "Maxx";

      case ChipCategory.stix:
        return "Stix";

      case ChipCategory.stax:
        return "Stax";

      case ChipCategory.baked:
        return "Из печи";

      case ChipCategory.ridged:
        return "Рифленные";
    }
  }
}

class ChipRating {
  final double average;
  final int count;
  final int? userRating;

  const ChipRating({
    required this.average,
    required this.count,
    this.userRating,
  });

  factory ChipRating.fromJson(
    Map<String, dynamic> json
  ) {
    return ChipRating(
      average: json["average"],
      count: json["count"],
      userRating: json["user_rating"],
    );
  }
}

class LaysChip {
  final int id;

  final String name;
  final ChipCategory category;
  final String description;
  final String imagePath;
  final bool available;
  final ChipRating rating;
  final String collection;
  final String country;
  final int releaseYear;
  final int discontinuedYear;
  final int commentCount;

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
    required this.discontinuedYear,
    required this.commentCount,
  });


  factory LaysChip.fromJson(Map<String, dynamic> json) {
    return LaysChip(
      id: json["id"],
      name: json["name"],
      category: ChipCategory.values.firstWhere((e) => e.name == json["category"]),
      description: json["description"],
      imagePath: json["image_path"],
      available: json["available"],
      collection: json["collection"],
      country: json["country"],
      releaseYear: json["release_year"],
      discontinuedYear: json["discontinued_year"],
      commentCount: json["comment_count"] ?? 0,

      rating: ChipRating.fromJson(
        json["rating"],
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
      discontinuedYear: discontinuedYear,
      commentCount: commentCount,

      rating: rating ?? this.rating,
    );
  }
}
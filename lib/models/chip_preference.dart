class ChipPreference {
  final int? rating;
  final bool isFavorite;
  final bool isTried;

  ChipPreference({
    this.rating,
    required this.isFavorite,
    required this.isTried,
  });

  factory ChipPreference.fromJson(Map<String, dynamic> json) {
    return ChipPreference(
      rating: json["rating"],
      isFavorite: json["is_favorite"] ?? false,
      isTried: json["is_tried"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "rating": rating,
      "is_favorite": isFavorite,
      "is_tried": isTried,
    };
  }
}
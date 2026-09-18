class UserFilters {
  const UserFilters({
    required this.filters,
    required this.russiaOnly,
    required this.availableOnly,
  });

  final List<String> filters;
  final bool russiaOnly;
  final bool availableOnly;

  factory UserFilters.fromJson(Map<String, dynamic> json) {
    return UserFilters(
      filters: (json['filters'] as List?)?.cast<String>() ?? [],
      russiaOnly: json['russia_only'] as bool? ?? false,
      availableOnly: json['available_only'] as bool? ?? false,
    );
  }

  UserFilters copyWith({
    List<String>? filters,
    bool? russiaOnly,
    bool? availableOnly,
  }) {
    return UserFilters(
      filters: filters ?? this.filters,
      russiaOnly: russiaOnly ?? this.russiaOnly,
      availableOnly: availableOnly ?? this.availableOnly,
    );
  }
}
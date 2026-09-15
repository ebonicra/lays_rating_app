class PollData {
  final String question;
  final List<PollOption> options;
  final int totalVotes;
  final int? myVote; // индекс варианта, за который голосовал пользователь (null = не голосовал)

  const PollData({
    required this.question,
    required this.options,
    required this.totalVotes,
    this.myVote,
  });

  factory PollData.fromJson(Map<String, dynamic> json) {
    return PollData(
      question: json['question'] ?? '',
      options: (json['options'] as List)
          .map((o) => PollOption.fromJson(o))
          .toList(),
      totalVotes: json['total_votes'] ?? 0,
      myVote: json['my_vote'],
    );
  }

  PollData copyWith({
    List<PollOption>? options,
    int? totalVotes,
    int? myVote,
    bool clearMyVote = false, // ← новый параметр
  }) {
    return PollData(
      question: question,
      options: options ?? this.options,
      totalVotes: totalVotes ?? this.totalVotes,
      myVote: clearMyVote ? null : (myVote ?? this.myVote),
    );
  }
}

class PollOption {
  final String text;
  final String? imagePath;
  final int votes;

  const PollOption({
    required this.text,
    this.imagePath,
    required this.votes,
  });

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      text: json['text'] ?? '',
      imagePath: json['image_path'],
      votes: json['votes'] ?? 0,
    );
  }

  PollOption copyWith({int? votes}) {
    return PollOption(
      text: text,
      imagePath: imagePath,
      votes: votes ?? this.votes,
    );
  }
}
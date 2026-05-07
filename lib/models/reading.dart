class Reading {
  final String question;
  final String answer;
  final DateTime timestamp;
  final bool isFavorite;

  const Reading({
    required this.question,
    required this.answer,
    required this.timestamp,
    this.isFavorite = false,
  });

  Reading copyWith({
    String? question,
    String? answer,
    DateTime? timestamp,
    bool? isFavorite,
  }) {
    return Reading(
      question: question ?? this.question,
      answer: answer ?? this.answer,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
        'timestamp': timestamp.toIso8601String(),
        'isFavorite': isFavorite,
      };

  factory Reading.fromJson(Map<String, dynamic> json) => Reading(
        question: json['question'] as String,
        answer: json['answer'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        isFavorite: json['isFavorite'] as bool? ?? false,
      );
}

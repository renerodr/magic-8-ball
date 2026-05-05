class Reading {
  final String question;
  final String answer;
  final DateTime timestamp;

  const Reading({
    required this.question,
    required this.answer,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Reading.fromJson(Map<String, dynamic> json) => Reading(
        question: json['question'] as String,
        answer: json['answer'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

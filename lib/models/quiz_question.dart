class QuizQuestion {
  final String question;
  final List<String> options;
  final String answer;
  final String description;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
    required this.description,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['Question'],
      options: List<String>.from(json['Options']),
      answer: json['Answer'],
      description: json['Description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Question': question,
      'Options': options,
      'Answer': answer,
      'Description': description,
    };
  }
}
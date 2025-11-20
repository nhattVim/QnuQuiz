class QuestionOptionModel {
  final int id;
  final String content;
  final bool correct;

  QuestionOptionModel({
    required this.id,
    required this.content,
    required this.correct,
  });

  factory QuestionOptionModel.fromJson(Map<String, dynamic> json) {
    return QuestionOptionModel(
      id: json['id'] as int,
      content: json['content'],
      correct: json['correct'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'correct': correct,
  };
}

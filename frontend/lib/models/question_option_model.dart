class QuestionOptionModel {
  final int id;
  final String content;
  final bool correct;
  final int? position;

  QuestionOptionModel({
    required this.id,
    required this.content,
    required this.correct,
    this.position,
  });

  factory QuestionOptionModel.fromJson(Map<String, dynamic> json) {
    return QuestionOptionModel(
      id: json['id'] as int,
      content: json['content'],
      correct: json['correct'],
      position: json['position'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'correct': correct,
    'position': position,
  };
}

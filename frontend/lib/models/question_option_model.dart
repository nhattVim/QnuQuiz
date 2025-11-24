class QuestionOptionModel {
  final int id;
  final String content;
  final bool isCorrect;
  final int? position;

  QuestionOptionModel({
    required this.id,
    required this.content,
    required this.isCorrect,
    this.position,
  });

  factory QuestionOptionModel.fromJson(Map<String, dynamic> json) {
    return QuestionOptionModel(
      id: json['id'] as int,
      content: json['content'],
      isCorrect: json['correct'],
      position: json['position'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'isCorrect': isCorrect,
    'position': position,
  };
}

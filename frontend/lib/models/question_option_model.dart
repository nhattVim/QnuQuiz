class QuestionOptionModel {
  final int id;
  final String content;
  final bool isCorrect;

  QuestionOptionModel({
    required this.id,
    required this.content,
    required this.isCorrect,
  });

  factory QuestionOptionModel.fromJson(Map<String, dynamic> json) {
    return QuestionOptionModel(
      id: json['id'] as int,
      content: json['content'],
      isCorrect: json['correct'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'isCorrect': isCorrect,
  };
}

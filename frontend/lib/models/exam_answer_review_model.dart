class ExamAnswerReviewModel {
  final int questionId;
  final String questionText;
  final int selectedOptionId;
  final int correctOptionId;
  final bool isCorrect;

  ExamAnswerReviewModel({
    required this.questionId,
    required this.questionText,
    required this.selectedOptionId,
    required this.correctOptionId,
    required this.isCorrect,
  });

  factory ExamAnswerReviewModel.fromJson(Map<String, dynamic> json) {
    return ExamAnswerReviewModel(
      questionId: json['questionId'] as int,
      questionText: json['questionText'] as String,
      selectedOptionId: json['selectedOptionId'] as int,
      correctOptionId: json['correctOptionId'] as int,
      isCorrect: json['isCorrect'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'selectedOptionId': selectedOptionId,
      'correctOptionId': correctOptionId,
      'isCorrect': isCorrect,
    };
  }
}

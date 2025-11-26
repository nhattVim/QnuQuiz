class ExamAnswerHistoryModel {
  final int questionId;
  final String questionContent;
  final bool isCorrect;
  final String? answerText;
  final int? selectedOptionId;
  final String? selectedOptionContent;

  ExamAnswerHistoryModel({
    required this.questionId,
    required this.questionContent,
    required this.isCorrect,
    this.answerText,
    this.selectedOptionId,
    this.selectedOptionContent,
  });

  factory ExamAnswerHistoryModel.fromJson(Map<String, dynamic> json) {
    return ExamAnswerHistoryModel(
      questionId: json['questionId'] as int,
      questionContent: json['questionContent'] as String,
      isCorrect: json['isCorrect'] as bool? ?? false,
      answerText: json['answerText'] as String?,
      selectedOptionId: json['selectedOptionId'] as int?,
      selectedOptionContent: json['selectedOptionContent'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionContent': questionContent,
      'isCorrect': isCorrect,
      'answerText': answerText,
      'selectedOptionId': selectedOptionId,
      'selectedOptionContent': selectedOptionContent,
    };
  }
}


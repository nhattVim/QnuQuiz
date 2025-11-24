import 'package:frontend/models/question_option_model.dart';

class ExamAnswerReviewModel {
  final int questionId;
  final String questionText;
  final String? type; // MULTIPLE_CHOICE, TRUE_FALSE
  final int? selectedOptionId;
  final int correctOptionId;
  final bool isCorrect;
  final List<QuestionOptionModel> options;

  ExamAnswerReviewModel({
    required this.questionId,
    required this.questionText,
    this.type,
    required this.selectedOptionId,
    required this.correctOptionId,
    required this.isCorrect,
    required this.options,
  });

  factory ExamAnswerReviewModel.fromJson(Map<String, dynamic> json) {
    // Parse studentAnswer: "2" → 2 (nullable)
    int? selected = int.tryParse(json['studentAnswer'] ?? "");

    // Parse options list
    List<QuestionOptionModel> opts = (json['options'] as List)
        .map((o) => QuestionOptionModel.fromJson(o))
        .toList();

    // Find correct option ID
    final correctOption = opts.firstWhere(
      (o) => o.correct == true,
      orElse: () => QuestionOptionModel(id: 0, content: "", correct: false),
    );

    return ExamAnswerReviewModel(
      questionId: json['questionId'],
      questionText: json['questionContent'],
      type: json['type'],
      selectedOptionId: selected,
      correctOptionId: correctOption.id,
      isCorrect: json['correct'],
      options: opts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'type': type,
      'selectedOptionId': selectedOptionId,
      'correctOptionId': correctOptionId,
      'isCorrect': isCorrect,
      'options': options.map((e) => e.toJson()).toList(),
    };
  }
}

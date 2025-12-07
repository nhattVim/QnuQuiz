import 'package:frontend/models/exam_answer_history_model.dart';

class ExamHistoryModel {
  final int attemptId;
  final int examId;
  final String examTitle;
  final String? examDescription;
  final double? score;
  final DateTime? completionDate;
  final int? durationMinutes;
  final List<ExamAnswerHistoryModel> answers;

  ExamHistoryModel({
    required this.attemptId,
    required this.examId,
    required this.examTitle,
    this.examDescription,
    this.score,
    this.completionDate,
    this.durationMinutes,
    this.answers = const [],
  });

  factory ExamHistoryModel.fromJson(Map<String, dynamic> json) {
    List<ExamAnswerHistoryModel> answersList = [];
    if (json['answers'] != null && json['answers'] is List) {
      answersList = (json['answers'] as List)
          .map((e) => ExamAnswerHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return ExamHistoryModel(
      attemptId: json['attemptId'] as int,
      examId: json['examId'] as int,
      examTitle: json['examTitle'] as String,
      examDescription: json['examDescription'] as String?,
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'] as String).toLocal()
          : null,
      durationMinutes: json['durationMinutes'] != null
          ? json['durationMinutes'] as int
          : null,
      answers: answersList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attemptId': attemptId,
      'examId': examId,
      'examTitle': examTitle,
      'examDescription': examDescription,
      'score': score,
      'completionDate': completionDate?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'answers': answers.map((e) => e.toJson()).toList(),
    };
  }
}

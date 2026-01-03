import 'package:frontend/models/exam_answer_history_model.dart';

class ExamHistoryModel {
  final int attemptId;
  final int examId;
  final String examTitle;
  final String? examDescription;
  final double? score;
  final DateTime? completionDate;
  final DateTime? startTime;
  final int? durationMinutes;
  final int? examDurationMinutes; // Tổng thời gian của bài thi
  final List<ExamAnswerHistoryModel> answers;

  ExamHistoryModel({
    required this.attemptId,
    required this.examId,
    required this.examTitle,
    this.examDescription,
    this.score,
    this.completionDate,
    this.startTime,
    this.durationMinutes,
    this.examDurationMinutes,
    this.answers = const [],
  });

  // Helper getter to check if exam is completed
  bool get isCompleted => completionDate != null;

  // Tính thời gian còn lại (giây)
  int get remainingSeconds {
    if (examDurationMinutes == null || startTime == null) {
      return 0;
    }
    final totalSeconds = examDurationMinutes! * 60;
    final elapsedSeconds = DateTime.now().difference(startTime!).inSeconds;
    final remaining = totalSeconds - elapsedSeconds;
    return remaining > 0 ? remaining : 0;
  }

  factory ExamHistoryModel.fromJson(Map<String, dynamic> json) {
    List<ExamAnswerHistoryModel> answersList = [];
    if (json['answers'] != null && json['answers'] is List) {
      answersList = (json['answers'] as List)
          .map(
            (e) => ExamAnswerHistoryModel.fromJson(e as Map<String, dynamic>),
          )
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
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String).toLocal()
          : null,
      durationMinutes: json['durationMinutes'] != null
          ? json['durationMinutes'] as int
          : null,
      examDurationMinutes: json['examDurationMinutes'] != null
          ? json['examDurationMinutes'] as int
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
      'startTime': startTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'examDurationMinutes': examDurationMinutes,
      'answers': answers.map((e) => e.toJson()).toList(),
    };
  }
}

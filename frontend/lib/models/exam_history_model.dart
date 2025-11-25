class ExamHistoryModel {
  final int attemptId;
  final int examId;
  final String examTitle;
  final String? examDescription;
  final double? score;
  final DateTime? completionDate;
  final int? durationMinutes;

  ExamHistoryModel({
    required this.attemptId,
    required this.examId,
    required this.examTitle,
    this.examDescription,
    this.score,
    this.completionDate,
    this.durationMinutes,
  });

  factory ExamHistoryModel.fromJson(Map<String, dynamic> json) {
    return ExamHistoryModel(
      attemptId: json['attemptId'] as int,
      examId: json['examId'] as int,
      examTitle: json['examTitle'] as String,
      examDescription: json['examDescription'] as String?,
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'] as String)
          : null,
      durationMinutes: json['durationMinutes'] != null
          ? json['durationMinutes'] as int
          : null,
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
    };
  }
}

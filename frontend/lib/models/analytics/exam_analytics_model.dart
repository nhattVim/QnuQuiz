class ExamAnalytics {
  final int examId;
  final String examTitle;
  final int totalAttempts;
  final int totalSubmitted;
  final double avgScore;
  final double maxScore;
  final double minScore;

  ExamAnalytics({
    required this.examId,
    required this.examTitle,
    required this.totalAttempts,
    required this.totalSubmitted,
    required this.avgScore,
    required this.maxScore,
    required this.minScore,
  });

  factory ExamAnalytics.fromJson(Map<String, dynamic> json) {
    return ExamAnalytics(
      examId: json['examId'],
      examTitle: json['examTitle'],
      totalAttempts: json['totalAttempts'],
      totalSubmitted: json['totalSubmitted'],
      avgScore: (json['avgScore'] as num?)?.toDouble() ?? 0.0,
      maxScore: (json['maxScore'] as num?)?.toDouble() ?? 0.0,
      minScore: (json['minScore'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

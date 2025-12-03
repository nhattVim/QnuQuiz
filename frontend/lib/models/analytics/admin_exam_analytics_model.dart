class AdminExamAnalyticsModel {
  final int totalExams;
  final int activeExams;
  final double averageQuestionsPerExam;
  final double averageAttemptsPerExam;
  final double overallAverageScore;

  AdminExamAnalyticsModel({
    required this.totalExams,
    required this.activeExams,
    required this.averageQuestionsPerExam,
    required this.averageAttemptsPerExam,
    required this.overallAverageScore,
  });

  factory AdminExamAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AdminExamAnalyticsModel(
      totalExams: json['totalExams'],
      activeExams: json['activeExams'],
      averageQuestionsPerExam: json['averageQuestionsPerExam'],
      averageAttemptsPerExam: json['averageAttemptsPerExam'],
      overallAverageScore: json['overallAverageScore'],
    );
  }

  Map<String, dynamic> toJson() => {
        'totalExams': totalExams,
        'activeExams': activeExams,
        'averageQuestionsPerExam': averageQuestionsPerExam,
        'averageAttemptsPerExam': averageAttemptsPerExam,
        'overallAverageScore': overallAverageScore,
      };
}

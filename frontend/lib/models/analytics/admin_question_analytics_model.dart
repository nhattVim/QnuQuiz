class AdminQuestionAnalyticsModel {
  final int totalQuestions;
  final int multipleChoiceQuestions;
  final int trueFalseQuestions;
  final double averageOptionsPerQuestion;
  final double averageUsageInExams;

  AdminQuestionAnalyticsModel({
    required this.totalQuestions,
    required this.multipleChoiceQuestions,
    required this.trueFalseQuestions,
    required this.averageOptionsPerQuestion,
    required this.averageUsageInExams,
  });

  factory AdminQuestionAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AdminQuestionAnalyticsModel(
      totalQuestions: json['totalQuestions'],
      multipleChoiceQuestions: json['multipleChoiceQuestions'],
      trueFalseQuestions: json['trueFalseQuestions'],
      averageOptionsPerQuestion: json['averageOptionsPerQuestion'],
      averageUsageInExams: json['averageUsageInExams'],
    );
  }

  Map<String, dynamic> toJson() => {
        'totalQuestions': totalQuestions,
        'multipleChoiceQuestions': multipleChoiceQuestions,
        'trueFalseQuestions': trueFalseQuestions,
        'averageOptionsPerQuestion': averageOptionsPerQuestion,
        'averageUsageInExams': averageUsageInExams,
      };
}

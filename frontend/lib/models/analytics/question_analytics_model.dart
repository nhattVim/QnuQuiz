class QuestionAnalytics {
  final String questionContent;
  final int totalAnswers;
  final int correctCount;
  final int wrongCount;
  final double correctRate;

  QuestionAnalytics({
    required this.questionContent,
    required this.totalAnswers,
    required this.correctCount,
    required this.wrongCount,
    required this.correctRate,
  });

  factory QuestionAnalytics.fromJson(Map<String, dynamic> json) {
    return QuestionAnalytics(
      questionContent: json['questionContent'],
      totalAnswers: json['totalAnswers'],
      correctCount: json['correctCount'],
      wrongCount: json['wrongCount'],
      correctRate: (json['correctRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

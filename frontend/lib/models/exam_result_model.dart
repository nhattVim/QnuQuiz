class ExamResultModel {
  final double score;
  final int correctCount;
  final int totalQuestions;

  ExamResultModel({
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
  });

  factory ExamResultModel.fromJson(Map<String, dynamic> json) {
    return ExamResultModel(
      score: (json['score'] as num).toDouble(),
      correctCount: json['correctCount'] as int,
      totalQuestions: json['totalQuestions'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'correctCount': correctCount,
      'totalQuestions': totalQuestions,
    };
  }
}

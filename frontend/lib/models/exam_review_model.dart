import 'package:frontend/models/exam_answer_review_model.dart';

class ExamReviewModel {
  final int examAttemptId;
  final String examTitle;
  final double score;
  final List answers;

  ExamReviewModel({
    required this.examAttemptId,
    required this.examTitle,
    required this.score,
    required this.answers,
  });

  factory ExamReviewModel.fromJson(Map<String, dynamic> json) {
    var answersJson = json['answers'] as List? ?? [];
    List answerList = answersJson
        .map((e) => ExamAnswerReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return ExamReviewModel(
      examAttemptId: json['examAttemptId'] as int,
      examTitle: json['examTitle'] as String,
      score: (json['score'] as num).toDouble(),
      answers: answerList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'examAttemptId': examAttemptId,
      'examTitle': examTitle,
      'score': score,
      'answers': answers.map((e) => e.toJson()).toList(),
    };
  }
}

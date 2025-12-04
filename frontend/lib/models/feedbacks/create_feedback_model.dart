class CreateFeedbackModel {
  final int? questionId;
  final int? examId;
  final String content;
  final int rating;

  CreateFeedbackModel({
    this.questionId,
    this.examId,
    required this.content,
    required this.rating,
  });

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'examId': examId,
    'content': content,
    'rating': rating,
  };
}

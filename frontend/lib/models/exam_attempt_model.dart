class ExamAttemptModel {
  final int id;
  final int examId;
  final DateTime startTime;
  final bool submit;

  ExamAttemptModel({
    required this.id,
    required this.examId,
    required this.startTime,
    required this.submit,
  });

  factory ExamAttemptModel.fromJson(Map<String, dynamic> json) {
    return ExamAttemptModel(
      id: json['id'] as int,
      examId: json['examId'] as int,
      startTime: DateTime.parse(json['startTime'] as String),
      submit: json['submit'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'examId': examId,
      'startTime': startTime.toIso8601String(),
      'submit': submit,
    };
  }
}

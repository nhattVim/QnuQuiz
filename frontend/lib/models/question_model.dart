import 'package:frontend/models/question_option_model.dart';

class QuestionModel {
  final int? id;
  final String? content;
  final String? type; // e.g., MULTIPLE_CHOICE, TRUE_FALSE
  final int? examId;
  final List<QuestionOptionModel>? options;

  QuestionModel({
    this.id,
    this.content,
    this.type,
    this.examId,
    this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as int?,
      content: json['content'],
      type: json['type'],
      examId: json['examId'] as int?,
      options: (json['options'] as List?)
          ?.map<QuestionOptionModel>(
            (option) => QuestionOptionModel.fromJson(option),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type,
      'examId': examId,
      'options': options?.map((option) => option.toJson()).toList(),
    };
  }
}

import 'package:frontend/models/question_option_model.dart';

class QuestionModel {
  final int id;
  final String content;
  final List<QuestionOptionModel> options;

  QuestionModel({
    required this.id,
    required this.content,
    required this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as int,
      content: json['content'],
      options: (json['options'] as List)
          .map<QuestionOptionModel>(
            (option) => QuestionOptionModel.fromJson(option),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'options': options.map((option) => option.toJson()).toList(),
    };
  }
}

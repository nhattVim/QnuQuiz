import 'package:frontend/models/question_option_model.dart';

class QuestionModel {
  final int id;
  final String content;
  final double point;
  final List<QuestionOptionModel> options;

  QuestionModel({
    required this.id,
    required this.content,
    required this.point,
    required this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as int,
      content: json['content'],
      point: (json['point'] as num).toDouble(),
      options: (json['options'] as List)
          .map<QuestionOptionModel>(
            (option) => QuestionOptionModel.fromJson(option),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'point': point,
      'options': options.map((option) => option.toJson()).toList(),
    };
  }
}

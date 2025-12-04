class FeedbackTemplateModel {
  final String code;
  final String label;
  final String content;

  FeedbackTemplateModel({
    required this.code,
    required this.label,
    required this.content,
  });

  factory FeedbackTemplateModel.fromJson(Map<String, dynamic> json) {
    return FeedbackTemplateModel(
      code: json['code'],
      label: json['label'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'label': label,
    'content': content,
  };
}

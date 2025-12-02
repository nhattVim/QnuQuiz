import 'package:frontend/models/user_model.dart';

class FeedbackModel {
  final int? id;
  final String? subject;
  final String content;
  final UserModel? user;
  final String? userEmail;
  final DateTime createdAt;

  FeedbackModel({
    this.id,
    this.subject,
    required this.content,
    this.user,
    this.userEmail,
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'],
      subject: json['subject'],
      content: json['content'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      userEmail: json['userEmail'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'content': content,
        'user': user?.toJson(),
        'userEmail': userEmail,
        'createdAt': createdAt.toIso8601String(),
      };
}

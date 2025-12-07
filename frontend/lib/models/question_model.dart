import 'package:frontend/models/media_file_model.dart';
import 'package:frontend/models/question_option_model.dart';

class QuestionModel {
  final int? id;
  final String? content;
  final String? type; // e.g., MULTIPLE_CHOICE, TRUE_FALSE
  final int? examId;
  final String? mediaUrl; // Deprecated: Use mediaFiles instead
  final List<MediaFileModel>? mediaFiles; // List of media files
  final List<QuestionOptionModel>? options;

  QuestionModel({
    this.id,
    this.content,
    this.type,
    this.examId,
    this.mediaUrl,
    this.mediaFiles,
    this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as int?,
      content: json['content'],
      type: json['type'],
      examId: json['examId'] as int?,
      mediaUrl: json['mediaUrl'] as String?,
      mediaFiles: (json['mediaFiles'] as List?)
          ?.map<MediaFileModel>(
            (media) => MediaFileModel.fromJson(media),
          )
          .toList(),
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
      'mediaUrl': mediaUrl,
      'mediaFiles': mediaFiles?.map((media) => media.toJson()).toList(),
      'options': options?.map((option) => option.toJson()).toList(),
    };
  }

  /// Convert to JSON for update requests
  /// Excludes mediaFiles as they are managed separately via MediaFileService
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'id': id,
      'content': content,
      'type': type,
      'examId': examId,
      'options': options?.map((option) => option.toJson()).toList(),
      // Note: mediaFiles are managed separately via MediaFileService
      // Do not include mediaFiles in update request
    };
  }
}

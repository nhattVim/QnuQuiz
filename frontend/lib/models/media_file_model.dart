class MediaFileModel {
  final int? id;
  final String? fileName;
  final String? fileUrl;
  final String? mimeType;
  final int? sizeBytes;
  final int? questionId;
  final String? description;
  final DateTime? createdAt;

  MediaFileModel({
    this.id,
    this.fileName,
    this.fileUrl,
    this.mimeType,
    this.sizeBytes,
    this.questionId,
    this.description,
    this.createdAt,
  });

  factory MediaFileModel.fromJson(Map<String, dynamic> json) {
    return MediaFileModel(
      id: json['id'] as int?,
      fileName: json['fileName'] as String?,
      fileUrl: json['fileUrl'] as String?,
      mimeType: json['mimeType'] as String?,
      sizeBytes: json['sizeBytes'] as int?,
      questionId: json['questionId'] as int?,
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
      'questionId': questionId,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}


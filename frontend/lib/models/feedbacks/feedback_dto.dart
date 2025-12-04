class FeedbackDto {
  final int? id;
  final String? questionContent;
  final String? userName;
  final String? reviewedBy;
  final String content;
  final String status;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  FeedbackDto({
    this.id,
    this.questionContent,
    this.userName,
    this.reviewedBy,
    required this.content,
    required this.status,
    required this.createdAt,
    this.reviewedAt,
  });

  factory FeedbackDto.fromJson(Map<String, dynamic> json) {
    return FeedbackDto(
      id: json['id'],
      questionContent: json['questionContent'],
      userName: json['userName'],
      reviewedBy: json['reviewedBy'],
      content: json['content'],
      status: json['status'] ?? 'PENDING',
      createdAt: DateTime.parse(json['createdAt']),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'questionContent': questionContent,
    'userName': userName,
    'reviewedBy': reviewedBy,
    'content': content,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'reviewedAt': reviewedAt?.toIso8601String(),
  };
}

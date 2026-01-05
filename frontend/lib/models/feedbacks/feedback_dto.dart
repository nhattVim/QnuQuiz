class FeedbackDto {
  final int? id;
  final String examContent;
  final String? questionContent;
  final String? userName;
  final String? reviewedBy;
  final String content;
  final int? rating;
  final String status;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? teacherReply;

  FeedbackDto({
    this.id,
    required this.examContent,
    this.questionContent,
    this.userName,
    this.reviewedBy,
    required this.content,
    this.rating,
    required this.status,
    required this.createdAt,
    this.reviewedAt,
    this.teacherReply,
  });

  factory FeedbackDto.fromJson(Map<String, dynamic> json) {
    return FeedbackDto(
      id: json['id'],
      examContent: json['examContent'],
      questionContent: json['questionContent'],
      userName: json['userName'],
      reviewedBy: json['reviewedBy'],
      content: json['content'],
      rating: json['rating'],
      status: json['status'] ?? 'PENDING',
      createdAt: DateTime.parse(json['createdAt']),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'])
          : null,
      teacherReply: json['teacherReply'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'examContent': examContent,
        'questionContent': questionContent,
        'userName': userName,
        'reviewedBy': reviewedBy,
        'content': content,
        'rating': rating,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'reviewedAt': reviewedAt?.toIso8601String(),
        'teacherReply': teacherReply,
      };
}

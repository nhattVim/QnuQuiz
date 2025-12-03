class AnnouncementModel {
  final int id;
  final String title;
  final String content;
  final String target;
  final int? classId;
  final String? className;
  final int? departmentId;
  final String? departmentName;
  final String? authorName;
  final DateTime publishedAt;
  final DateTime createdAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.target,
    this.classId,
    this.className,
    this.departmentId,
    this.departmentName,
    this.authorName,
    required this.publishedAt,
    required this.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      target: json['target'] as String,
      classId: json['classId'] as int?,
      className: json['className'] as String?,
      departmentId: json['departmentId'] as int?,
      departmentName: json['departmentName'] as String?,
      authorName: json['authorName'] as String?,
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String).toLocal()
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'target': target,
      'classId': classId,
      'className': className,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'authorName': authorName,
      'publishedAt': publishedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}


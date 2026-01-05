class TeacherStatsModel {
  final int teacherId;
  final String? teacherCode;
  final String? fullName;
  final int totalExams;
  final int totalQuestions;
  final int totalStudents;
  final int totalExamAttempts;
  final double averageScore;
  final int totalFeedbacks;

  TeacherStatsModel({
    required this.teacherId,
    this.teacherCode,
    this.fullName,
    required this.totalExams,
    required this.totalQuestions,
    required this.totalStudents,
    required this.totalExamAttempts,
    required this.averageScore,
    required this.totalFeedbacks,
  });

  factory TeacherStatsModel.fromJson(Map<String, dynamic> json) {
    return TeacherStatsModel(
      teacherId: json['teacherId'] ?? 0,
      teacherCode: json['teacherCode'],
      fullName: json['fullName'],
      totalExams: json['totalExams'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
      totalExamAttempts: json['totalExamAttempts'] ?? 0,
      averageScore: (json['averageScore'] ?? 0).toDouble(),
      totalFeedbacks: json['totalFeedbacks'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'teacherId': teacherId,
    'teacherCode': teacherCode,
    'fullName': fullName,
    'totalExams': totalExams,
    'totalQuestions': totalQuestions,
    'totalStudents': totalStudents,
    'totalExamAttempts': totalExamAttempts,
    'averageScore': averageScore,
    'totalFeedbacks': totalFeedbacks,
  };
}

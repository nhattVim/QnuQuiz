class ExamCategoryModel {
  final int id;
  final String name;
  final int totalExams;

  ExamCategoryModel({
    required this.id,
    required this.name,
    required this.totalExams,
  });

  factory ExamCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExamCategoryModel(
      id: json['id'],
      name: json['name'],
      totalExams: json['totalExams'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'totalExams': totalExams,
    };
  }
}

class ExamCategoryModel {
  final int id;
  final String name;
  final String? description;
  final DateTime? createdAt;

  ExamCategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
  });

  factory ExamCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExamCategoryModel(
      id: json['id'] as int,
      name: json['name'],
      description: json['description'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

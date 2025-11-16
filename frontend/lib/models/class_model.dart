class ClassModel {
  final int id;
  final String name;
  final int? departmentId;

  ClassModel({
    required this.id,
    required this.name,
    this.departmentId,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      departmentId: json['departmentId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'departmentId': departmentId,
      };
}


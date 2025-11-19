class TeacherModel {
  final int id;
  final String? userName;
  final String? departmentName;
  final String? teacherCode;
  final String? title;

  TeacherModel({
    required this.id,
    required this.userName,
    required this.departmentName,
    required this.teacherCode,
    required this.title,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] ?? 0,
      userName: json['userName'],
      departmentName: json['departmentName'],
      teacherCode: json['teacherCode'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userName': userName,
    'departmentName': departmentName,
    'teacherCode': teacherCode,
    'title': title,
  };
}

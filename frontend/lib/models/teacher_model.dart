class TeacherModel {
  final int id;
  final String? userId;
  final String? username;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final int? departmentId;
  final String? teacherCode;
  final String? title;
  final String? avatarUrl;

  TeacherModel({
    required this.id,
    this.userId,
    this.username,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.departmentId,
    this.teacherCode,
    this.title,
    this.avatarUrl,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] ?? 0,
      userId: json['userId'] as String?,
      username: json['username'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      departmentId: json['departmentId'],
      teacherCode: json['teacherCode'],
      title: json['title'],
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'username': username,
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
    'departmentId': departmentId,
    'teacherCode': teacherCode,
    'title': title,
    'avatarUrl': avatarUrl,
  };
}

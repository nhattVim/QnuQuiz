class StudentModel {
  final int id;
  final String? username;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final int? classId;
  final int? departmentId;
  final double? gpa;
  final String? avatarUrl;

  StudentModel({
    required this.id,
    this.username,
    this.gpa,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.departmentId,
    this.classId,
    this.avatarUrl,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] ?? 0,
      username: json['username'],
      gpa: json['gpa']?.toDouble(),
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      departmentId: json['departmentId'],
      classId: json['classId'],
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'gpa': gpa,
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
    'departmentId': departmentId,
    'classId': classId,
    'avatarUrl': avatarUrl,
  };
}

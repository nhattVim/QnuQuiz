class StudentModel {
  final int id;
  final String? className;
  final String? userName;
  final String? departmentName;
  final double? gpa;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final int? departmentId;
  final int? classId;

  StudentModel({
    required this.id,
    this.className,
    this.userName,
    this.departmentName,
    this.gpa,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.departmentId,
    this.classId,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] ?? 0,
      className: json['className'],
      userName: json['userName'],
      departmentName: json['departmentName'],
      gpa: json['gpa']?.toDouble(),
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      departmentId: json['departmentId'],
      classId: json['classId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'className': className,
    'userName': userName,
    'departmentName': departmentName,
    'gpa': gpa,
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
    'departmentId': departmentId,
    'classId': classId,
  };
}


class UserModel {
  final String id;
  final String username;
  final String email;
  final String role;
  final String? fullName;
  final String? phoneNumber;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.fullName,
    this.phoneNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'role': role,
    'fullName': fullName,
    'phoneNumber': phoneNumber,
  };

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? role,
    String? fullName,
    String? phoneNumber,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

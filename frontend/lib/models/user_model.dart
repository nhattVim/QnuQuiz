class UserModel {
  final String? id;
  final String username;
  final String email;
  final String role;
  final String? fullName;
  final String? phoneNumber;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.role,
    this.fullName,
    this.phoneNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      fullName: json['fullName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
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

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/constants/api_constants.dart';
import 'package:frontend/models/student_model.dart';
import 'package:frontend/models/teacher_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:logger/logger.dart';

import '../models/user_model.dart';

class UserService {
  final _log = Logger();
  final Dio _dio;
  final FlutterSecureStorage _storage;

  UserService({Dio? dio, FlutterSecureStorage? storage})
      : _dio = dio ?? ApiService().dio,
        _storage = storage ?? const FlutterSecureStorage();

  Future<void> clearUser() async {
    await _storage.delete(key: 'user');
  }

  Future<UserModel?> getUser() async {
    final data = await _storage.read(key: 'user');
    if (data == null) return null;
    return UserModel.fromJson(jsonDecode(data));
  }

  Future<void> saveUser(UserModel user) async {
    await _storage.write(key: 'user', value: jsonEncode(user.toJson()));
  }

  Future<UserModel> updateProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
    String? newPassword,
  }) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.users}/me/profile',
        data: {
          'fullName': fullName,
          'email': email,
          'phoneNumber': phoneNumber,
          if (newPassword != null && newPassword.isNotEmpty)
            'newPassword': newPassword,
        },
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi cập nhật thông tin');
    }
  }

  Future<dynamic> getCurrentUserProfile() async {
    try {
      final response = await _dio.get('${ApiConstants.users}/me');
      final Map<String, dynamic> data = response.data;

      final user = await getUser();
      final String role = user!.role;

      switch (role) {
        case 'STUDENT':
          return StudentModel.fromJson(data);
        case 'TEACHER':
          return TeacherModel.fromJson(data);
        case 'ADMIN':
          return UserModel.fromJson(data);
        default:
          return UserModel.fromJson(data);
      }
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(
        e.response?.data?['message'] ?? 'Lỗi lấy thông tin người dùng',
      );
    }
  }
}

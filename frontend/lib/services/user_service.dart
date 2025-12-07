import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/constants/api_constants.dart';
import 'package:frontend/models/student_model.dart';
import 'package:frontend/models/teacher_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:logger/logger.dart';

class UserService {
  final _log = Logger();
  final ApiService _apiService;
  final FlutterSecureStorage _storage;

  UserService(this._apiService, {FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Dio get _dio => _apiService.dio;

  Future<void> clearUser() async {
    await _storage.delete(key: 'user');
  }

  Future<UserModel> createUser(UserModel user) async {
    try {
      final response = await _dio.post(ApiConstants.users, data: user.toJson());
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi tạo người dùng');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _dio.delete('${ApiConstants.users}/$userId');
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi xóa người dùng');
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _dio.get(ApiConstants.users);
      final List<dynamic> data = response.data;
      return data.map((user) => UserModel.fromJson(user)).toList();
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(
        e.response?.data?['message'] ?? 'Lỗi lấy danh sách người dùng',
      );
    }
  }

  Future<dynamic> getCurrentUserProfile() async {
    try {
      final response = await _dio.get('${ApiConstants.users}/me');
      final Map<String, dynamic> data = response.data;

      final user = await getUser();
      if (user == null) throw Exception("Không tìm thấy thông tin user local");

      final String role = user.role;

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

  Future<UserModel> updateUser(UserModel user) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.users}/${user.id}',
        data: user.toJson(),
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(
        e.response?.data?['message'] ?? 'Lỗi cập nhật người dùng',
      );
    }
  }

  /// Import students from an Excel file (.xlsx).
  /// This calls the backend /api/students/import endpoint.
  Future<void> importStudents(String filePath) async {
    try {
      final fileName = filePath.split('/').last.split('\\').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      await _dio.post('${ApiConstants.students}/import', data: formData);
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(
        e.response?.data?['message'] ?? 'Lỗi import danh sách sinh viên',
      );
    }
  }
}

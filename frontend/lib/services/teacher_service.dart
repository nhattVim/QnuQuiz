import 'package:dio/dio.dart';
import 'package:frontend/constants/api_constants.dart';
import 'package:frontend/models/teacher_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:logger/logger.dart';

class TeacherService {
  final _log = Logger();
  final Dio _dio = ApiService().dio;

  Future<TeacherModel> getCurrentTeacher() async {
    try {
      final response = await _dio.get('${ApiConstants.teachers}/me');
      return TeacherModel.fromJson(response.data);
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(
        e.response?.data?['message'] ?? 'Lỗi lấy thông tin giảng viên',
      );
    }
  }

  Future<List<TeacherModel>> getAllTeachers() async {
    try {
      final response = await _dio.get(ApiConstants.teachers);
      final List<dynamic> data = response.data;
      return data.map((teacher) => TeacherModel.fromJson(teacher)).toList();
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(
        e.response?.data?['message'] ?? 'Lỗi lấy danh sách giảng viên',
      );
    }
  }

  Future<TeacherModel> updateProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
    required int? departmentId,
    required String? title,
    String? newPassword,
  }) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.teachers}/me/profile',
        data: {
          'fullName': fullName,
          'email': email,
          'phoneNumber': phoneNumber,
          'departmentId': departmentId,
          'title': title,
          if (newPassword != null && newPassword.isNotEmpty)
            'newPassword': newPassword,
        },
      );
      return TeacherModel.fromJson(response.data);
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi cập nhật thông tin');
    }
  }
}

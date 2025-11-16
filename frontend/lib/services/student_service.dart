import 'package:dio/dio.dart';
import 'package:frontend/constants/api_constants.dart';
import 'package:frontend/models/student_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:logger/logger.dart';

class StudentService {
  final _log = Logger();
  final Dio _dio = ApiService().dio;

  Future<StudentModel> getCurrentStudent() async {
    try {
      // Get current student from the list (assuming first one is current user)
      // TODO: Replace with actual endpoint when available: /api/students/me
      final response = await _dio.get('${ApiConstants.students}');
      final data = response.data;
      
      if (data is List && data.isNotEmpty) {
        // For now, return first student. In future, use /me endpoint
        return StudentModel.fromJson(data[0] as Map<String, dynamic>);
      }
      throw Exception('Không tìm thấy thông tin sinh viên');
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi lấy thông tin sinh viên');
    }
  }

  Future<StudentModel> updateProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
    required int? departmentId,
    required int? classId,
    String? newPassword,
  }) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.students}/me/profile',
        data: {
          'fullName': fullName,
          'email': email,
          'phoneNumber': phoneNumber,
          'departmentId': departmentId,
          'classId': classId,
          if (newPassword != null && newPassword.isNotEmpty)
            'newPassword': newPassword,
        },
      );
      return StudentModel.fromJson(response.data);
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi cập nhật thông tin');
    }
  }
}


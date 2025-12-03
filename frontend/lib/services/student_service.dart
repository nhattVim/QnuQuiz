import 'package:dio/dio.dart';
import 'package:frontend/constants/api_constants.dart';
import 'package:frontend/models/exam_history_model.dart';
import 'package:frontend/models/student_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:logger/logger.dart';

class StudentService {
  final _log = Logger();
  final ApiService _apiService;

  StudentService(this._apiService);

  Dio get _dio => _apiService.dio;

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

  Future<List<ExamHistoryModel>> getExamHistory() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.students}/me/exam-history',
      );
      final data = response.data;

      if (data is List) {
        return data
            .map((e) => ExamHistoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data.containsKey('message')) {
        throw Exception(data['message']);
      } else {
        throw Exception('Unexpected data format: $data');
      }
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(
        e.response?.data?['message'] ?? 'Lỗi tải lịch sử làm bài',
      );
    }
  }
}

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:frontend/constants/api_constants.dart';
import 'package:frontend/models/analytics/admin_exam_analytics_model.dart';
import 'package:frontend/models/analytics/admin_question_analytics_model.dart';
import 'package:frontend/models/analytics/class_performance_model.dart';
import 'package:frontend/models/analytics/exam_analytics_model.dart';
import 'package:frontend/models/analytics/question_analytics_model.dart';
import 'package:frontend/models/analytics/score_distribution_model.dart';
import 'package:frontend/models/analytics/student_attempt_model.dart';
import 'package:frontend/models/analytics/user_analytics_model.dart';
import 'package:frontend/models/ranking_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:logger/logger.dart';

class AnalyticsService {
  final _log = Logger();
  final ApiService _apiService;

  AnalyticsService(this._apiService);

  Dio get _dio => _apiService.dio;

  Future<List<ExamAnalytics>> getExamAnalytics(String teacherId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.analytics}/teacher/$teacherId/exams',
      );
      final data = response.data;

      if (data is List) {
        return data
            .map((e) => ExamAnalytics.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Unexpected data format');
      }
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi kết nối');
    }
  }

  Future<List<ClassPerformance>> getClassPerformance(int examId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.analytics}/exam/$examId/class-performance',
      );
      final data = response.data;

      if (data is List) {
        return data
            .map((e) => ClassPerformance.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Unexpected data format');
      }
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi kết nối');
    }
  }

  Future<List<ScoreDistribution>> getScoreDistribution(String teacherId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.analytics}/teacher/$teacherId/score-distribution',
      );
      final data = response.data;

      if (data is List) {
        return data
            .map((e) => ScoreDistribution.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Unexpected data format');
      }
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi kết nối');
    }
  }

  Future<List<StudentAttempt>> getStudentAttempts(int examId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.analytics}/exam/$examId/attempts',
      );
      final data = response.data;

      if (data is List) {
        return data
            .map((e) => StudentAttempt.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Unexpected data format');
      }
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi kết nối');
    }
  }

  Future<List<QuestionAnalytics>> getQuestionAnalytics(int examId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.analytics}/exam/$examId/question-analytics',
      );
      final data = response.data;

      if (data is List) {
        return data
            .map((e) => QuestionAnalytics.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Unexpected data format');
      }
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi kết nối');
    }
  }

  Future<List<RankingModel>> getRankingAll() async {
    try {
      final response = await _dio.get('${ApiConstants.analytics}/ranking');
      final data = response.data;

      if (data is List) {
        return data
            .map((e) => RankingModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data.containsKey('message')) {
        throw Exception(data['message']);
      } else {
        throw Exception('Unexpected data format: $data');
      }
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi kết nối');
    }
  }

  Future<List<RankingModel>> getRankingAllThisWeek() async {
    try {
      final response = await _dio.get('${ApiConstants.analytics}/ranking/week');
      final data = response.data;

      if (data is List) {
        return data
            .map((e) => RankingModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data.containsKey('message')) {
        throw Exception(data['message']);
      } else {
        throw Exception('Unexpected data format: $data');
      }
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi kết nối');
    }
  }

  Future<List<RankingModel>> getRankingByExamId(int examId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.analytics}/ranking/$examId',
      );
      final data = response.data;

      if (data is List) {
        return data
            .map((e) => RankingModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data.containsKey('message')) {
        throw Exception(data['message']);
      } else {
        throw Exception('Unexpected data format: $data');
      }
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi kết nối');
    }
  }

  Future<UserAnalyticsModel> getUserAnalytics() async {
    try {
      final response = await _dio.get('${ApiConstants.analytics}/admin/users');
      return UserAnalyticsModel.fromJson(response.data);
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(
        e.response?.data?['message'] ?? 'Lỗi lấy thống kê người dùng',
      );
    }
  }

  Future<AdminExamAnalyticsModel> getAdminExamAnalytics() async {
    try {
      final response = await _dio.get('${ApiConstants.analytics}/admin/exams');
      return AdminExamAnalyticsModel.fromJson(response.data);
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(
        e.response?.data?['message'] ?? 'Lỗi lấy thống kê bài thi',
      );
    }
  }

  Future<AdminQuestionAnalyticsModel> getAdminQuestionAnalytics() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.analytics}/admin/questions',
      );
      return AdminQuestionAnalyticsModel.fromJson(response.data);
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(
        e.response?.data?['message'] ?? 'Lỗi lấy thống kê câu hỏi',
      );
    }
  }

  /// Download CSV for user analytics (admin only).
  Future<List<int>> downloadUserAnalyticsCsv() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.analytics}/admin/users/export',
        options: Options(responseType: ResponseType.bytes),
      );
      
      if (response.statusCode != 200) {
        final errorMessage = _parseErrorFromBytes(response.data);
        throw Exception(errorMessage ?? 'Lỗi export thống kê người dùng');
      }
      
      if (response.data is List<int>) {
        final bytes = response.data as List<int>;
        if (_isErrorResponse(bytes)) {
          final errorMessage = _parseErrorFromBytes(bytes);
          throw Exception(errorMessage ?? 'Lỗi export thống kê người dùng');
        }
        return bytes;
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      final errorMessage = _parseErrorFromBytes(e.response?.data);
      _log.e('DioException: ${errorMessage ?? e.message}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('Endpoint export chưa được triển khai trên backend');
      }
      
      throw Exception(
        errorMessage ?? 'Lỗi export thống kê người dùng',
      );
    } catch (e) {
      _log.e('Unexpected error: $e');
      rethrow;
    }
  }

  /// Download CSV for exam analytics (admin only).
  Future<List<int>> downloadExamAnalyticsCsv() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.analytics}/admin/exams/export',
        options: Options(responseType: ResponseType.bytes),
      );
      
      if (response.statusCode != 200) {
        final errorMessage = _parseErrorFromBytes(response.data);
        throw Exception(errorMessage ?? 'Lỗi export thống kê bài thi');
      }
      
      if (response.data is List<int>) {
        final bytes = response.data as List<int>;
        if (_isErrorResponse(bytes)) {
          final errorMessage = _parseErrorFromBytes(bytes);
          throw Exception(errorMessage ?? 'Lỗi export thống kê bài thi');
        }
        return bytes;
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      final errorMessage = _parseErrorFromBytes(e.response?.data);
      _log.e('DioException: ${errorMessage ?? e.message}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('Endpoint export chưa được triển khai trên backend');
      }
      
      throw Exception(
        errorMessage ?? 'Lỗi export thống kê bài thi',
      );
    } catch (e) {
      _log.e('Unexpected error: $e');
      rethrow;
    }
  }

  /// Download CSV for question analytics (admin only).
  Future<List<int>> downloadQuestionAnalyticsCsv() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.analytics}/admin/questions/export',
        options: Options(responseType: ResponseType.bytes),
      );
      
      if (response.statusCode != 200) {
        final errorMessage = _parseErrorFromBytes(response.data);
        throw Exception(errorMessage ?? 'Lỗi export thống kê câu hỏi');
      }
      
      if (response.data is List<int>) {
        final bytes = response.data as List<int>;
        if (_isErrorResponse(bytes)) {
          final errorMessage = _parseErrorFromBytes(bytes);
          throw Exception(errorMessage ?? 'Lỗi export thống kê câu hỏi');
        }
        return bytes;
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      final errorMessage = _parseErrorFromBytes(e.response?.data);
      _log.e('DioException: ${errorMessage ?? e.message}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('Endpoint export chưa được triển khai trên backend');
      }
      
      throw Exception(
        errorMessage ?? 'Lỗi export thống kê câu hỏi',
      );
    } catch (e) {
      _log.e('Unexpected error: $e');
      rethrow;
    }
  }

  bool _isErrorResponse(List<int> bytes) {
    try {
      final jsonString = String.fromCharCodes(bytes);
      final json = jsonDecode(jsonString);
      return json is Map && (json.containsKey('error') || json.containsKey('message'));
    } catch (e) {
      return false;
    }
  }

  String? _parseErrorFromBytes(dynamic data) {
    if (data == null) return null;
    
    try {
      if (data is List<int>) {
        final jsonString = String.fromCharCodes(data);
        final json = jsonDecode(jsonString) as Map<String, dynamic>?;
        if (json != null) {
          if (json.containsKey('message')) {
            return json['message'] as String?;
          }
          if (json.containsKey('error')) {
            return json['error'] as String?;
          }
        }
      }
    } catch (e) {
      _log.w('Failed to parse error from bytes: $e');
    }
    
    return null;
  }
}

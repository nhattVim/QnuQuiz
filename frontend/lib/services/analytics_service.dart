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
  Future<Response<dynamic>> downloadUserAnalyticsCsv() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.analytics}/admin/users/export',
        options: Options(responseType: ResponseType.bytes),
      );
      return response;
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(
        e.response?.data?['message'] ?? 'Lỗi export thống kê người dùng',
      );
    }
  }

  /// Download CSV for exam analytics (admin only).
  Future<Response<dynamic>> downloadExamAnalyticsCsv() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.analytics}/admin/exams/export',
        options: Options(responseType: ResponseType.bytes),
      );
      return response;
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(
        e.response?.data?['message'] ?? 'Lỗi export thống kê bài thi',
      );
    }
  }

  /// Download CSV for question analytics (admin only).
  Future<Response<dynamic>> downloadQuestionAnalyticsCsv() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.analytics}/admin/questions/export',
        options: Options(responseType: ResponseType.bytes),
      );
      return response;
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(
        e.response?.data?['message'] ?? 'Lỗi export thống kê câu hỏi',
      );
    }
  }
}

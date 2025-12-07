import 'package:dio/dio.dart';
import 'package:frontend/constants/api_constants.dart';
import 'package:frontend/models/exam_attempt_model.dart';
import 'package:frontend/models/exam_category_model.dart';
import 'package:frontend/models/exam_model.dart';
import 'package:frontend/models/exam_result_model.dart';
import 'package:frontend/models/exam_review_model.dart';
import 'package:frontend/models/question_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:logger/logger.dart';

class ExamService {
  final _log = Logger();
  final ApiService _apiService;

  ExamService(this._apiService);

  Dio get _dio => _apiService.dio;

  Future<List<ExamModel>> getExamsByUserId(bool sort) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.exams}/user',
        queryParameters: {'sort': sort == true ? "asc" : "desc"},
      );
      final data = response.data;

      if (data is List) {
        return data
            .map((e) => ExamModel.fromJson(e as Map<String, dynamic>))
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

  Future<ExamModel> updateExam(ExamModel exam) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.exams}/update/${(exam.id)}',
        data: exam.toJson(),
      );
      return ExamModel.fromJson(response.data);
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi kết nối');
    }
  }

  Future<ExamModel> createExam(ExamModel exam) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.exams}/create',
        data: exam.toJson(),
      );
      return ExamModel.fromJson(response.data);
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi kết nối');
    }
  }

  Future<void> deleteExam(int id) async {
    try {
      final response = await _dio.delete('${ApiConstants.exams}/delete/$id');
      if (response.statusCode == 200) {
        _log.i('Đã xóa câu hỏi');
      } else {
        throw Exception('Xóa thất bại: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi kết nối');
    }
  }

  Future<List<ExamModel>> getAllExams() async {
    try {
      final response = await _dio.get('${ApiConstants.exams}/getAll');
      final data = response.data;

      if (data is List) {
        return data
            .map((e) => ExamModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Unexpected data format');
      }
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi kết nối');
    }
  }

  Future<List<ExamCategoryModel>> getAllCategories() async {
    try {
      final response = await _dio.get('${ApiConstants.exams}/categories');
      final data = response.data;

      if (data is List) {
        return data
            .map((e) => ExamCategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Unexpected data format');
      }
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi kết nối');
    }
  }

  Future<List<ExamModel>> getExamsByCategory(int categoryId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.exams}/categories/$categoryId',
      );
      final data = response.data;

      if (data is List) {
        return data
            .map((e) => ExamModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data.containsKey("message")) {
        throw Exception(data["message"]);
      } else {
        throw Exception("Unexpected data format");
      }
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?["message"] ?? "Lỗi kết nối");
    }
  }

  // Bắt đầu bài thi
  Future startExam(int examId) async {
    try {
      final response = await _dio.post('${ApiConstants.exams}/$examId/start');
      return ExamAttemptModel.fromJson(response.data);
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi kết nối');
    }
  }

  // Nộp câu trả lời
  Future submitAnswer({
    required int attemptId,
    required int questionId,
    required int optionId,
  }) async {
    try {
      await _dio.post(
        '${ApiConstants.exams}/$attemptId/answer/$questionId/$optionId',
      );
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi kết nối');
    }
  }

  // Kết thúc bài thi
  Future finishExam(int attemptId) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.exams}/$attemptId/finish',
      );
      return ExamResultModel.fromJson(response.data);
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi kết nối');
    }
  }

  // Xem lại kết quả bài thi
  Future reviewExamAttempt(int attemptId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.exams}/attempts/$attemptId/review',
      );

      // _log.i("📌 RESPONSE: ${response.data}");
      return ExamReviewModel.fromJson(response.data);
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi kết nối');
    }
  }

  // Lấy latest attempt mà không tạo mới
  Future getLatestAttempt(int examId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.exams}/$examId/latest-attempt',
      );
      return ExamAttemptModel.fromJson(response.data);
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi kết nối');
    }
  }

  Future<List<QuestionModel>> getQuestionByExam(int examId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.exams}/$examId/questions',
      );

      final data = response.data;

      if (data is List) {
        return data
            .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
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
}

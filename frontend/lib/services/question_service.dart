import 'dart:io';

import 'package:dio/dio.dart';
import 'package:frontend/constants/api_constants.dart';
import 'package:frontend/models/question_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:logger/logger.dart';

class QuestionService {
  final _log = Logger();
  final ApiService _apiService;

  QuestionService(this._apiService);

  Dio get _dio => _apiService.dio;

  Future<List<QuestionModel>> getQuestions(int examId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.questions}/exam/$examId',
        queryParameters: {'examId': examId},
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

  Future<void> importQuestions(File file, int examId) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '${ApiConstants.questions}/import',
        queryParameters: {'examId': examId},
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200) {
        _log.i('Import thành công: ${response.data}');
      } else {
        throw Exception('Import thất bại: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi kết nối');
    }
  }

  Future<List<QuestionModel>> getAllQuestions() async {
    try {
      final response = await _dio.get(ApiConstants.questions);
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
      throw Exception(
        e.response?.data?['message'] ?? 'Lỗi lấy danh sách câu hỏi',
      );
    }
  }

  Future<void> deleteQuestions(List<int> questionIds) async {
    if (questionIds.isEmpty) return;

    try {
      final response = await _dio.delete(
        ApiConstants.questions,
        data: {'ids': questionIds},
      );

      if (response.statusCode == 200) {
        _log.i('Đã xóa ${questionIds.length} câu hỏi');
      } else {
        throw Exception('Xóa thất bại: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi kết nối khi xóa');
    }
  }

  Future<QuestionModel> updateQuestion(QuestionModel question) async {
    try {
      // Use toJsonForUpdate() to exclude mediaFiles
      // Media files are managed separately via MediaFileService
      // Backend endpoint is PUT /api/questions/{id} (not /update/{id})
      final response = await _dio.put(
        '${ApiConstants.questions}/${question.id}',
        data: question.toJsonForUpdate(),
      );
      return QuestionModel.fromJson(response.data);
    } on DioException catch (e) {
      _log.e('Error updating question: ${e.response?.data ?? e.message}');
      // Provide more detailed error message
      final errorMessage = e.response?.data?['message'] ?? 
          e.response?.data?['error'] ?? 
          'Lỗi kết nối';
      throw Exception(errorMessage);
    } catch (e) {
      _log.e('Unexpected error updating question: $e');
      rethrow;
    }
  }

  Future<QuestionModel> createQuestion(
    Map<String, dynamic> questionData,
    int examId,
  ) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.questions}/create',
        data: questionData,
        queryParameters: {'examId': examId},
      );
      return QuestionModel.fromJson(response.data);
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi khi tạo câu hỏi');
    }
  }
}

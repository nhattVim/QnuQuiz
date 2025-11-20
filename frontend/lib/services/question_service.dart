import 'dart:io';

import 'package:dio/dio.dart';
import 'package:frontend/constants/api_constants.dart';
import 'package:frontend/models/question_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:logger/logger.dart';

class QuestionService {
  final _log = Logger();
  final Dio _dio = ApiService().dio;

  Future<List<QuestionModel>> getQuestions(int examId) async {
    try {
      final response = await _dio.get(
        ApiConstants.questions,
        queryParameters: {'examId': examId},
      );
      _log.i("📌 RESPONSE: ${response.data}");
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

  Future<void> deleteQuestions(List<int> questionIds) async {
    if (questionIds.isEmpty) return;

    try {
      final response = await _dio.delete(
        '${ApiConstants.questions}/delete',
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
}

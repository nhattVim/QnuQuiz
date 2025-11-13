import 'package:dio/dio.dart';
import 'package:frontend/constants/api_constants.dart';
import 'package:frontend/models/exam_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:logger/logger.dart';

class ExamService {
  final _log = Logger();
  final Dio _dio = ApiService().dio;

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
        '${ApiConstants.exams}/update',
        data: exam.toJson(),
      );
      return ExamModel.fromJson(response.data);
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi kết nối');
    }
  }
}

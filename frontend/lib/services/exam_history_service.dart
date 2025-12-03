import 'package:dio/dio.dart';
import 'package:frontend/constants/api_constants.dart';
import 'package:frontend/models/exam_history_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:logger/logger.dart';

class ExamHistoryService {
  final _log = Logger();
  final Dio _dio = ApiService().dio;

  Future<List<ExamHistoryModel>> getExamHistory() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.students}/me/exam-history',
      );

      final data = response.data;

      if (data is List) {
        return data
            .map((e) => ExamHistoryModel.fromJson(e))
            .toList();
      } else {
        throw Exception("Dữ liệu trả về không hợp lệ");
      }
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? "Lỗi kết nối server");
    }
  }
}

import 'package:dio/dio.dart';
import 'package:frontend/constants/api_constants.dart';
import 'package:frontend/models/feedback_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:logger/logger.dart';

class FeedbackService {
  final _log = Logger();
  final ApiService _apiService;

  FeedbackService(this._apiService);

  Dio get _dio => _apiService.dio;

  Future<List<FeedbackModel>> getAllFeedbacks() async {
    try {
      final response = await _dio.get(ApiConstants.feedbacks);
      final List<dynamic> data = response.data;
      return data.map((json) => FeedbackModel.fromJson(json)).toList();
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(
        e.response?.data?['message'] ?? 'Lỗi lấy danh sách phản hồi',
      );
    }
  }

  Future<void> deleteFeedback(int id) async {
    try {
      await _dio.delete('${ApiConstants.feedbacks}/$id');
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi xóa phản hồi');
    }
  }
}

import 'package:dio/dio.dart';
import 'package:frontend/constants/api_constants.dart';
import 'package:frontend/models/feedback_model.dart';
import 'package:frontend/models/feedbacks/create_feedback_model.dart';
import 'package:frontend/models/feedbacks/feedback_dto.dart';
import 'package:frontend/models/feedbacks/update_feedback_model.dart';
import 'package:frontend/models/feedbacks/teacher_reply_model.dart';
import 'package:frontend/models/feedbacks/feedback_template_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:logger/logger.dart';

class FeedbackService {
  final _log = Logger();
  final ApiService _apiService;

  FeedbackService(this._apiService);

  Dio get _dio => _apiService.dio;

  /// Lấy tất cả phản hồi
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

  /// Lấy phản hồi cho một câu hỏi cụ thể
  Future<List<FeedbackDto>> getFeedbacksForQuestion(
    int questionId, {
    String? status,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (status != null) {
        params['status'] = status;
      }

      final response = await _dio.get(
        '${ApiConstants.feedbacks}/question/$questionId',
        queryParameters: params,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => FeedbackDto.fromJson(json)).toList();
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(
        e.response?.data?['message'] ?? 'Lỗi lấy phản hồi cho câu hỏi',
      );
    }
  }

  /// Lấy phản hồi cho một kỳ thi cụ thể
  Future<List<FeedbackDto>> getFeedbacksForExam(
    int examId, {
    String? status,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (status != null) {
        params['status'] = status;
      }

      final response = await _dio.get(
        '${ApiConstants.feedbacks}/exam/$examId',
        queryParameters: params,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => FeedbackDto.fromJson(json)).toList();
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(
        e.response?.data?['message'] ?? 'Lỗi lấy phản hồi cho kỳ thi',
      );
    }
  }

  /// Tạo phản hồi mới
  Future<FeedbackDto> createFeedback(CreateFeedbackModel request) async {
    try {
      final response = await _dio.post(
        ApiConstants.feedbacks,
        data: request.toJson(),
      );
      return FeedbackDto.fromJson(response.data);
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi tạo phản hồi');
    }
  }

  /// Cập nhật phản hồi
  Future<FeedbackDto> updateFeedback(
    int id,
    UpdateFeedbackModel request,
  ) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.feedbacks}/$id',
        data: request.toJson(),
      );
      return FeedbackDto.fromJson(response.data);
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi cập nhật phản hồi');
    }
  }

  /// Xóa phản hồi
  Future<void> deleteFeedback(int id) async {
    try {
      await _dio.delete('${ApiConstants.feedbacks}/$id');
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(e.response?.data?['message'] ?? 'Lỗi xóa phản hồi');
    }
  }

  /// Thêm phản hồi từ giáo viên
  Future<FeedbackDto> addTeacherReply(
    int id,
    TeacherReplyModel request,
  ) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.feedbacks}/$id/reply',
        data: request.toJson(),
      );
      return FeedbackDto.fromJson(response.data);
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(
        e.response?.data?['message'] ?? 'Lỗi thêm phản hồi từ giáo viên',
      );
    }
  }

  /// Lấy danh sách template phản hồi
  Future<List<FeedbackTemplateModel>> getTemplates() async {
    try {
      final response = await _dio.get('${ApiConstants.feedbacks}/templates');
      final List<dynamic> data = response.data;
      return data.map((json) => FeedbackTemplateModel.fromJson(json)).toList();
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(
        e.response?.data?['message'] ?? 'Lỗi lấy template phản hồi',
      );
    }
  }
}

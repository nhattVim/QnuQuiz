import 'package:dio/dio.dart';
import 'package:frontend/constants/api_constants.dart';
import 'package:frontend/models/faq_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:logger/logger.dart';

class FaqService {
  final _log = Logger();
  final ApiService _apiService;

  FaqService(this._apiService);

  Dio get _dio => _apiService.dio;

  /// Lấy tất cả FAQ
  Future<List<FaqDto>> getAllFaqs() async {
    try {
      final response = await _dio.get(ApiConstants.faqs);
      final List<dynamic> data = response.data;
      return data.map((e) => FaqDto.fromJson(e)).toList();
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(
        e.response?.data?['message'] ?? 'Lỗi lấy danh sách FAQ',
      );
    }
  }

  /// Tìm kiếm FAQ theo câu hỏi
  Future<List<FaqDto>> searchFaq(String question) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.faqs}/search',
        queryParameters: {'question': question},
      );

      final List<dynamic> data = response.data;
      return data.map((e) => FaqDto.fromJson(e)).toList();
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(
        e.response?.data?['message'] ?? 'Lỗi tìm kiếm FAQ',
      );
    }
  }

  /// Cập nhật FAQ (admin)
  Future<FaqDto> updateFaq(FaqDto request) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.faqs}/update',
        data: {
          'id': request.id,
          'question': request.question,
          'answer': request.answer,
        },
      );
      return FaqDto.fromJson(response.data);
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(
        e.response?.data?['message'] ?? 'Lỗi cập nhật FAQ',
      );
    }
  }
}
import 'package:dio/dio.dart';
import 'package:frontend/constants/api_constants.dart';
import 'package:frontend/models/ranking_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:logger/logger.dart';

class AnalyticsService {
  final _log = Logger();
  final Dio _dio;

  AnalyticsService({Dio? dio}) : _dio = dio ?? ApiService().dio;

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
}

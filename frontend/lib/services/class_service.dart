import 'package:dio/dio.dart';
import 'package:frontend/constants/api_constants.dart';
import 'package:frontend/models/class_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:logger/logger.dart';

class ClassService {
  final _log = Logger();
  final Dio _dio = ApiService().dio;

  Future<List<ClassModel>> getClassesByDepartment(int departmentId) async {
    try {
      // TODO: Replace with actual API endpoint when available
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/api/classes',
        queryParameters: {'departmentId': departmentId},
      );
      final data = response.data;

      if (data is List) {
        return data
            .map((e) => ClassModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data.containsKey('message')) {
        throw Exception(data['message']);
      } else {
        return [];
      }
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      // Return empty list if API doesn't exist yet
      return [];
    }
  }

  Future<List<ClassModel>> getAllClasses() async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/api/classes');
      final data = response.data;

      if (data is List) {
        return data
            .map((e) => ClassModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data.containsKey('message')) {
        throw Exception(data['message']);
      } else {
        return [];
      }
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      return [];
    }
  }
}


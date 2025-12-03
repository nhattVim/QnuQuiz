import 'package:dio/dio.dart';
import 'package:frontend/constants/api_constants.dart';
import 'package:frontend/models/department_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:logger/logger.dart';

class DepartmentService {
  final _log = Logger();
  final Dio _dio = ApiService().dio;

  Future<List<DepartmentModel>> getAllDepartments() async {
    try {
      // TODO: Replace with actual API endpoint when available
      // For now, return empty list or mock data
      final response = await _dio.get('${ApiConstants.baseUrl}/api/departments');
      final data = response.data;

      if (data is List) {
        return data
            .map((e) => DepartmentModel.fromJson(e as Map<String, dynamic>))
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
}


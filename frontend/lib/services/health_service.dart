import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../constants/api_constants.dart';

class HealthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  final _log = Logger();

  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get(ApiConstants.health);
      if (response.statusCode == 200 && response.data['status'] == 'UP') {
        _log.i('Server is healthy');
        return true;
      }
    } catch (e) {
      _log.e('Health check failed: $e');
    }
    return false;
  }
}

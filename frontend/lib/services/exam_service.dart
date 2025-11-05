import 'package:dio/dio.dart';
import 'package:frontend/constants/api_constants.dart';
import 'package:frontend/models/exam_model.dart';
import 'package:logger/logger.dart';
import 'auth_service.dart';

final _log = Logger();

class ExamService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  ExamService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AuthService().getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<List<ExamModel>> getExamsByUserId() async {
    try {
      final response = await _dio.get('${ApiConstants.exams}/user');
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
}

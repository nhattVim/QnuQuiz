import 'package:dio/dio.dart';
import 'package:frontend/constants/api_constants.dart';
import 'package:frontend/services/auth_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio dio;

  ApiService._internal() {
    dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final token = await AuthService().getToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return handler.next(options);
          },
          onError: (e, handler) {
            return handler.next(e);
          },
        ),
      );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/constants/api_constants.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:logger/logger.dart';

class AuthService {
  final ApiService _apiService;
  final FlutterSecureStorage _storage;
  final _log = Logger();

  AuthService(this._apiService, {FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Dio get _dio => _apiService.dio;

  Future<String?> getToken() async => await _storage.read(key: 'auth_token');

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.auth}/login',
        data: {'username': username, 'password': password},
      );

      final userJson = response.data['user'];
      final user = UserModel.fromJson(userJson);

      return {'success': true, 'token': response.data['token'], 'user': user};
    } on DioException catch (e) {
      _log.e(e.response?.data);
      final message = e.response?.data['message'] ?? 'Lỗi kết nối';
      return {'success': false, 'message': message};
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user');
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
}

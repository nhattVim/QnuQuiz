import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiConstants {
  static const baseUrl = 'http://192.168.45.48:8080';
  static const auth = '/api/auth';
}

const _storage = FlutterSecureStorage();

class AuthService {
  Future<String?> getToken() async => await _storage.read(key: 'auth_token');

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<Map<String, dynamic>> login({
    required String studentId,
    required String password,
  }) async {
    final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    try {
      final response = await dio.post(
        '${ApiConstants.auth}/login',
        data: {'username': studentId, 'password': password},
      );
      return {'success': true, 'token': response.data['token']};
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Lỗi kết nối';
      return {'success': false, 'message': message};
    }
  }
}

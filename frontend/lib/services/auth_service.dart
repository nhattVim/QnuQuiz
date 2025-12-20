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
      final statusCode = e.response?.statusCode;
      final error = e.response?.data['error'];
      final message = e.response?.data['message'] ?? 'Lỗi kết nối';
      return {
        'success': false,
        'message': message,
        'statusCode': statusCode,
        'error': error,
      };
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user');
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.auth}/forgot-password',
        data: {'email': email},
      );

      return {
        'success': true,
        'message': response.data['message'] ?? 'Mã xác thực đã được gửi',
      };
    } on DioException catch (e) {
      _log.e(e.response?.data);
      final message = e.response?.data['message'] ?? 
                     e.response?.data['error'] ?? 
                     'Email chưa được đăng ký trong hệ thống';
      return {'success': false, 'message': message};
    }
  }

  Future<Map<String, dynamic>> verifyResetCode(String email, String code) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.auth}/verify-reset-code',
        data: {'email': email, 'code': code},
      );

      return {
        'success': true,
        'message': response.data['message'] ?? 'Mã xác thực hợp lệ',
      };
    } on DioException catch (e) {
      _log.e(e.response?.data);
      final message = e.response?.data['message'] ?? 
                     e.response?.data['error'] ?? 
                     'Mã xác thực không đúng hoặc đã hết hạn';
      return {'success': false, 'message': message};
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String email,
    String code,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.auth}/reset-password',
        data: {
          'email': email,
          'code': code,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      return {
        'success': true,
        'message': response.data['message'] ?? 'Đặt lại mật khẩu thành công',
      };
    } on DioException catch (e) {
      _log.e(e.response?.data);
      final message = e.response?.data['message'] ?? 
                     e.response?.data['error'] ?? 
                     'Có lỗi xảy ra khi đặt lại mật khẩu';
      return {'success': false, 'message': message};
    }
  }
}

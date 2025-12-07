import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/service_providers.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/services/auth_service.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  late final AuthService _authService;

  @override
  AuthState build() {
    _authService = ref.read(authServiceProvider);
    return AuthState.initial;
  }

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  Future<bool> login(String username, String password) async {
    state = AuthState.loading;
    _errorMessage = null;

    final result = await _authService.login(
      username: username,
      password: password,
    );

    if (result['success'] == true) {
      await _authService.saveToken(result['token']);
      final user = result['user'];
      ref.read(userProvider.notifier).setUser(user);
      state = AuthState.authenticated;
      return true;
    } else {
      final statusCode = result['statusCode'];
      final error = result['error'];
      
      if (statusCode == 401 || error == 'Unauthorized') {
        _errorMessage = 'Sai tên đăng nhập hoặc mật khẩu';
      } else {
        _errorMessage = result['message'] ?? 'Sai tên đăng nhập hoặc mật khẩu';
      }
      
      state = AuthState.error;
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    ref.read(userProvider.notifier).clearUser();
    state = AuthState.unauthenticated;
  }
}

enum AuthState { initial, authenticated, unauthenticated, loading, error }

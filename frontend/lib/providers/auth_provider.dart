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

  Future<void> login(String username, String password) async {
    state = AuthState.loading;

    final result = await _authService.login(
      username: username,
      password: password,
    );

    if (result['success'] == true) {
      await _authService.saveToken(result['token']);
      final user = result['user'];
      ref.read(userProvider.notifier).setUser(user);
      state = AuthState.authenticated;
    } else {
      state = AuthState.error;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    ref.read(userProvider.notifier).clearUser();
    state = AuthState.unauthenticated;
  }
}

enum AuthState { initial, authenticated, unauthenticated, loading, error }

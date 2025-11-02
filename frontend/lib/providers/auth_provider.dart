import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/services/user_service.dart';

import '../services/auth_service.dart';

enum AuthState { initial, authenticated, unauthenticated, loading, error }

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial);

  Future<void> login(String username, String password) async {
    state = AuthState.loading;
    final result = await AuthService().login(
      username: username,
      password: password,
    );
    if (result['success'] == true) {
      await AuthService().saveToken(result['token']);
      final user = result['user'];
      await UserService().saveUser(user);
      state = AuthState.authenticated;
    } else {
      state = AuthState.error;
    }
  }

  Future<void> logout() async {
    await AuthService().logout();
    state = AuthState.unauthenticated;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

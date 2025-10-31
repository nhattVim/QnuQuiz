import 'package:flutter_riverpod/legacy.dart';

import '../services/auth_service.dart';

enum AuthState { initial, authenticated, unauthenticated, loading, error }

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial);

  Future<void> login(String username, String password) async {
    state = AuthState.loading;
    final result = await AuthService().login(
      studentId: username,
      password: password,
    );
    if (result['success'] == true) {
      await AuthService().saveToken(result['token']);
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

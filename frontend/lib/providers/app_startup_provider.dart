import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/service_providers.dart';
import 'package:frontend/providers/user_provider.dart';

final appStartupProvider =
    AsyncNotifierProvider<AppStartupNotifier, AppStartupResult>(
      () => AppStartupNotifier(),
    );

class AppStartupNotifier extends AsyncNotifier<AppStartupResult> {
  Timer? _retryTimer;

  @override
  Future<AppStartupResult> build() async {
    ref.onDispose(() {
      _retryTimer?.cancel();
    });

    return _checkHealthAndLogin();
  }

  Future<AppStartupResult> _checkHealthAndLogin() async {
    state = const AsyncValue.loading();

    final isServerUp = await ref.read(healthServiceProvider).checkHealth();

    if (!isServerUp) {
      _retryTimer?.cancel();
      _retryTimer = Timer(const Duration(seconds: 3), () {
        if (!ref.mounted) return;
        ref.invalidateSelf();
      });

      return AppStartupResult(
        state: AppStartupState.serverDown,
        isServerUp: false,
      );
    }

    // Server up → restore session by checking BOTH token and cached user
    final authService = ref.read(authServiceProvider);
    final token = await authService.getToken();
    final cachedUser = await ref.read(userServiceProvider).getUser();

    final hasSession = token != null && token.isNotEmpty && cachedUser != null;

    if (hasSession) {
      // Keep in-memory user state in sync so UI can read immediately
      ref.read(userProvider.notifier).setUser(cachedUser);
      return AppStartupResult(
        state: AppStartupState.loggedIn,
        isServerUp: true,
        isLoggedIn: true,
      );
    }

    // Missing token or user → treat as logged out and clear leftovers
    await authService.logout();
    await ref.read(userProvider.notifier).clearUser();
    return AppStartupResult(
      state: AppStartupState.loggedOut,
      isServerUp: true,
      isLoggedIn: false,
    );
  }
}

class AppStartupResult {
  final AppStartupState state;
  final bool isServerUp;
  final bool? isLoggedIn;

  AppStartupResult({
    required this.state,
    required this.isServerUp,
    this.isLoggedIn,
  });
}

enum AppStartupState { checkingHealth, serverDown, loggedIn, loggedOut }

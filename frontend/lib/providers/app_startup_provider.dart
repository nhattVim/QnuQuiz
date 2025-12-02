import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/service_providers.dart';

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

    // Server up → check login
    final isLoggedIn = await ref
        .read(authServiceProvider)
        .isLoggedIn(); // Use provider

    if (isLoggedIn) {
      return AppStartupResult(
        state: AppStartupState.loggedIn,
        isServerUp: true,
        isLoggedIn: true,
      );
    } else {
      return AppStartupResult(
        state: AppStartupState.loggedOut,
        isServerUp: true,
        isLoggedIn: false,
      );
    }
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

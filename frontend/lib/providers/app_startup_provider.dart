import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/health_service.dart';
import '../services/auth_service.dart';

enum AppStartupState { checkingHealth, serverDown, loggedIn, loggedOut }

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

final appStartupProvider =
    AsyncNotifierProvider<AppStartupNotifier, AppStartupResult>(
      // AppStartupNotifier.new,
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

    final isServerUp = await HealthService().checkHealth();

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
    final isLoggedIn = await AuthService().isLoggedIn();

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

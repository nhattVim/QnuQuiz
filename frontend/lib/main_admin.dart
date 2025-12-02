import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/admin/pages/admin_dashboard_page.dart';
import 'package:frontend/admin/pages/admin_login_page.dart';
import 'package:frontend/constants/theme_constants.dart';
import 'package:frontend/providers/app_startup_provider.dart';
import 'package:frontend/screens/splash_screen.dart';

void main() {
  runApp(const ProviderScope(child: AdminApp()));
}

class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupAsync = ref.watch(appStartupProvider);

    return MaterialApp(
      title: 'QnuQuiz Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeConstants.lightTheme,
      darkTheme: ThemeConstants.darkTheme,
      themeMode: ThemeMode.system,
      home: startupAsync.when(
        loading: () => const SplashScreen(),
        error: (_, _) => const SplashScreen(),
        data: (result) {
          switch (result.state) {
            case AppStartupState.serverDown:
              return const SplashScreen();
            case AppStartupState.loggedIn:
              return const AdminDashboardPage();
            case AppStartupState.loggedOut:
              return const AdminLoginPage();
            default:
              return const SplashScreen();
          }
        },
      ),
    );
  }
}

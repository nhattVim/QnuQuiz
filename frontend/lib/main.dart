import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'providers/app_startup_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupAsync = ref.watch(appStartupProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'QnuQuiz',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: startupAsync.when(
            loading: () => const SplashScreen(),
            error: (_, __) => const SplashScreen(),
            data: (result) {
              switch (result.state) {
                case AppStartupState.serverDown:
                  return const SplashScreen();
                case AppStartupState.loggedIn:
                  return const HomeScreen();
                case AppStartupState.loggedOut:
                  return const LoginScreen();
                default:
                  return const SplashScreen();
              }
            },
          ),
        );
      },
    );
  }
}

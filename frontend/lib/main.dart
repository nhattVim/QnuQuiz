import 'dart:io' show Platform;

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'constants/theme_constants.dart';
import 'providers/app_startup_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    DevicePreview(
      enabled:
          !kReleaseMode &&
          (kIsWeb ||
              Platform.isWindows ||
              Platform.isLinux ||
              Platform.isMacOS),
      builder: (constext) => const ProviderScope(child: MyApp()),
    ),
  );
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
      useInheritedMediaQuery: true,
      builder: (context, child) {
        ScreenUtil.configure(data: MediaQuery.of(context));
        return MaterialApp(
          builder: (context, child) {
            return DevicePreview.appBuilder(context, child!);
          },
          debugShowCheckedModeBanner: false,
          title: 'QnuQuiz',
          theme: ThemeData(
            primaryColor: ThemeConstants.kColorPrimary,
            primarySwatch: ThemeConstants.kColorPrimary,
          ),
          home: startupAsync.when(
            loading: () => const SplashScreen(),
            error: (_, _) => const SplashScreen(),
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

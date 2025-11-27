import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:frontend/main.dart' as app;
import 'package:frontend/screens/home_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('S1.2 - Đăng nhập bằng MSGV (teacher1 / 123456)', (tester) async {
    // Khởi động app
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Helpers không dùng key
    Finder studentIdField() => find.byType(TextFormField).first;
    Finder passwordField() => find.byType(TextFormField).at(1);
    Finder loginButton() => find.widgetWithText(ElevatedButton, 'Đăng nhập');

    // Đảm bảo đang ở màn hình login (chưa vào HomeScreen)
    expect(find.byType(HomeScreen), findsNothing);
    expect(studentIdField(), findsOneWidget);
    expect(passwordField(), findsOneWidget);
    expect(loginButton(), findsOneWidget);

    // ==== TC02: Sai mật khẩu -> SnackBar lỗi ====
    await tester.enterText(studentIdField(), 'teacher1');
    await tester.enterText(passwordField(), 'sai_mat_khau');
    await tester.tap(loginButton());
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Đăng nhập thất bại'), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);

    // ==== TC03: Validate trống MSGV / mật khẩu ====
    // Trống MSGV
    await tester.enterText(studentIdField(), '');
    await tester.enterText(passwordField(), '123456');
    await tester.tap(loginButton());
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Vui lòng nhập tên đăng nhập'), findsOneWidget);

    // Mật khẩu < 6 ký tự
    await tester.enterText(studentIdField(), 'teacher1');
    await tester.enterText(passwordField(), '123');
    await tester.tap(loginButton());
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Mật khẩu ít nhất 6 ký tự'), findsOneWidget);

    // ==== TC01: Đăng nhập đúng teacher1 / 123456 -> vào HomeScreen ====
    await tester.enterText(studentIdField(), 'teacher1');
    await tester.enterText(passwordField(), '123456');
    await tester.tap(loginButton());
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}

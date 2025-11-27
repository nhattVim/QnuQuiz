import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:frontend/main.dart' as app;
import 'package:frontend/screens/home_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('S2.x - Màn hình quản lý câu hỏi (ExamDetailScreen)', (
    WidgetTester tester,
  ) async {
    // ==========  MỞ APP & ĐĂNG NHẬP TEACHER ==========

    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // helper cho màn hình login (dựa trên LoginScreen bạn gửi)
    Finder studentIdField() => find.byType(TextFormField).first;
    Finder passwordField() => find.byType(TextFormField).at(1);
    Finder loginButton() => find.widgetWithText(ElevatedButton, 'Đăng nhập');

    // đảm bảo đang ở màn hình login
    expect(studentIdField(), findsOneWidget);
    expect(passwordField(), findsOneWidget);
    expect(loginButton(), findsOneWidget);

    await tester.enterText(studentIdField(), 'teacher1');
    await tester.enterText(passwordField(), '123456');
    await tester.tap(loginButton());
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // đã vào HomeScreen (role TEACHER)
    expect(find.byType(HomeScreen), findsOneWidget);

    // ==========  CHUYỂN SANG TAB "Exam" ==========

    // Bottom nav dùng text label "Exam"
    await tester.tap(find.text('Exam'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // ==========  CHỌN ĐỀ "Thi cuối kỳ Java" ==========

    final examTile = find.text('Thi cuối kỳ Java');
    expect(examTile, findsWidgets); // có thể xuất hiện nhiều nơi
    await tester.tap(examTile.first);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // ==========  KIỂM TRA MÀN HÌNH CHI TIẾT ĐỀ THI ==========

    // Header "Danh sách câu hỏi"
    expect(find.text('Danh sách câu hỏi'), findsOneWidget);

    // Một vài control chính
    expect(find.text('Mô tả'), findsOneWidget);
    expect(find.text('Thời gian (phút)'), findsOneWidget);
    expect(find.text('Trạng thái'), findsOneWidget);
    expect(find.text('Bắt đầu'), findsOneWidget);
    expect(find.text('Kết thúc'), findsOneWidget);

    // ==========  XÓA CÂU HỎI ==========

    // Icon "Chọn để xóa"
    final deleteIcon = find.byIcon(Icons.delete_outline);
    expect(deleteIcon, findsOneWidget);

    await tester.tap(deleteIcon);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Đã hiện thanh xóa phía dưới
    expect(find.textContaining('Đã chọn'), findsOneWidget);
    expect(find.text('Đã chọn 0'), findsOneWidget);

    // Chọn 1 câu hỏi: lấy checkbox đầu tiên
    final firstCheckbox = find.byType(Checkbox).first;
    await tester.tap(firstCheckbox);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Đã chọn 1'), findsOneWidget);

    // Không thực sự bấm nút "Xóa" để tránh xóa dữ liệu thật
  });
}

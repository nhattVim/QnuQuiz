import 'package:flutter/material.dart';
import 'package:frontend/admin/pages/admin_dashboard_page.dart';

void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QnuQuiz Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AdminDashboardPage(),
    );
  }
}

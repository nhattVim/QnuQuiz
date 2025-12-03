import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/admin/pages/admin_login_page.dart';
import 'package:frontend/admin/pages/analytics_page.dart';
import 'package:frontend/admin/pages/exam_management_page.dart';
import 'package:frontend/admin/pages/feedback_management_page.dart';
import 'package:frontend/admin/pages/question_management_page.dart';
import 'package:frontend/admin/pages/user_management_page.dart';
import 'package:frontend/admin/widgets/admin_scaffold.dart';
import 'package:frontend/providers/auth_provider.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  // Use a list of maps or custom objects to hold both the page widget and its title
  static const List<Map<String, dynamic>> _adminPages = <Map<String, dynamic>>[
    {'title': 'Analytics', 'page': AnalyticsPage()},
    {'title': 'User Management', 'page': UserManagementPage()},
    {'title': 'Exam Management', 'page': ExamManagementPage()},
    {'title': 'Question Management', 'page': QuestionManagementPage()},
    {'title': 'Feedback Management', 'page': FeedbackManagementPage()},
    // {'title': 'Notification Management', 'page': NotificationManagementPage()},
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onDestinationSelected,
      onLogout: _handleLogout,
      pageTitle:
          _adminPages[_selectedIndex]['title'], // Pass the current page title
      body: _adminPages[_selectedIndex]['page'],
    );
  }

  void _handleLogout() async {
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginPage()),
      (route) => false,
    );
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

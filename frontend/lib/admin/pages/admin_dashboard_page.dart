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
  static const List<_AdminPageConfig> _adminPages = <_AdminPageConfig>[
    _AdminPageConfig(title: 'Analytics', page: AnalyticsPage()),
    _AdminPageConfig(title: 'User Management', page: UserManagementPage()),
    _AdminPageConfig(title: 'Exam Management', page: ExamManagementPage()),
    _AdminPageConfig(title: 'Question Management', page: QuestionManagementPage()),
    _AdminPageConfig(title: 'Feedback Management', page: FeedbackManagementPage()),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onDestinationSelected,
      onLogout: _handleLogout,
      pageTitle: _adminPages[_selectedIndex].title,
      body: _adminPages[_selectedIndex].page,
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

class _AdminPageConfig {
  const _AdminPageConfig({required this.title, required this.page});

  final String title;
  final Widget page;
}

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
  static const List<Widget> _pages = <Widget>[
    AnalyticsPage(),
    UserManagementPage(),
    ExamManagementPage(),
    QuestionManagementPage(),
    FeedbackManagementPage(),
    // NotificationManagementPage(),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onDestinationSelected,
      onLogout: _handleLogout,
      body: _pages[_selectedIndex],
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

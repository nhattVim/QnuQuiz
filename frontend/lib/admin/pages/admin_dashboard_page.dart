import 'package:flutter/material.dart';
import 'package:frontend/admin/widgets/admin_scaffold.dart';
import 'package:frontend/admin/pages/user_management_page.dart';
import 'package:frontend/admin/pages/analytics_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    Center(child: Text('Dashboard')),
    UserManagementPage(),
    AnalyticsPage(),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onDestinationSelected,
      body: _pages[_selectedIndex],
    );
  }
}

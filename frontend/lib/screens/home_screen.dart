import 'package:flutter/material.dart';
import 'package:frontend/models/nav_item.dart';
import 'package:frontend/pages/dashboard_page.dart';
import 'package:frontend/pages/faq_page.dart';
import 'package:frontend/pages/leaderboard_page.dart';
import 'package:frontend/pages/profile_page.dart';
import 'package:frontend/pages/question_page.dart';
import 'package:frontend/services/user_service.dart';
import '../models/user_model.dart';

const studentNav = [
  NavItem(page: DashboardPage(), icon: Icons.home_rounded, label: "Home"),
  NavItem(
    page: LeaderboardPage(),
    icon: Icons.leaderboard_rounded,
    label: "BXH",
  ),
  NavItem(page: FaqPage(), icon: Icons.help_outline_rounded, label: "FAQ"),
  NavItem(page: ProfilePage(), icon: Icons.person_rounded, label: "Profile"),
];

const teacherNav = [
  NavItem(
    page: QuestionPage(),
    icon: Icons.question_answer_rounded,
    label: "Questions",
  ),
  NavItem(page: DashboardPage(), icon: Icons.home_rounded, label: "Home"),
  NavItem(
    page: LeaderboardPage(),
    icon: Icons.leaderboard_rounded,
    label: "BXH",
  ),
  NavItem(page: ProfilePage(), icon: Icons.person_rounded, label: "Profile"),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  UserModel? _user;

  Future<void> _loadUser() async {
    final user = await UserService().getUser();
    setState(() => _user = user);
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final navItems = _user!.role == 'TEACHER' ? teacherNav : studentNav;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: navItems.map((e) => e.page).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey.shade500,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: navItems
            .map(
              (e) =>
                  BottomNavigationBarItem(icon: Icon(e.icon), label: e.label),
            )
            .toList(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/pages/exam_page.dart';
import '../models/nav_item.dart';
import '../pages/dashboard_page.dart';
import '../pages/faq_page.dart';
import '../pages/leaderboard_page.dart';
import '../pages/profile_page.dart';
import '../providers/user_provider.dart';

const dashboardItem = NavItem(
  page: DashboardPage(),
  icon: Icons.home_rounded,
  label: "Home",
);

const examItem = NavItem(
  page: ExamPage(),
  icon: Icons.library_books_sharp,
  label: "Exam",
);

const profileItem = NavItem(
  page: ProfilePage(),
  icon: Icons.person_rounded,
  label: "Profile",
);

const faqItem = NavItem(
  page: FaqPage(),
  icon: Icons.help_outline_rounded,
  label: "FAQ",
);

const leaderboardItem = NavItem(
  page: LeaderboardPage(),
  icon: Icons.leaderboard_rounded,
  label: "BXH",
);

const studentNav = [dashboardItem, leaderboardItem, faqItem, profileItem];
const teacherNav = [examItem, dashboardItem, leaderboardItem, profileItem];
const adminNav = [examItem, dashboardItem, profileItem];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final navItems = user.role == 'ADMIN'
        ? adminNav
        : (user.role == 'TEACHER' ? teacherNav : studentNav);

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

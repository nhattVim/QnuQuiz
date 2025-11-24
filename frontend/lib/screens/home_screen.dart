import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/models/nav_item.dart';
import 'package:frontend/pages/dashboard_page.dart';
import 'package:frontend/pages/faq_page.dart';
import 'package:frontend/pages/my_exam_page.dart';
import 'package:frontend/pages/profile_page.dart';
import 'package:frontend/pages/ranking_page.dart';
import '../pages/exam_list_page.dart';
import '../providers/user_provider.dart';

const dashboardItem = NavItem(
  page: DashboardPage(),
  icon: Icons.home_rounded,
  label: "Home",
);

const examItem = NavItem(
  page: MyExamPage(),
  icon: Icons.library_books_sharp,
  label: "Exam",
);

const examItem2 = NavItem(
  page: ExamListPage(),
  icon: Icons.library_books_sharp,
  label: "Exam",
);

const faqItem = NavItem(
  page: FaqPage(),
  icon: Icons.help_outline_rounded,
  label: "FAQ",
);

const rankingItem = NavItem(
  page: RankingPage(),
  icon: Icons.leaderboard_rounded,
  label: "BXH",
);

const profileItem = NavItem(
  page: ProfilePage(),
  icon: Icons.person_rounded,
  label: "Profile",
);

const adminNav = [examItem, dashboardItem, profileItem];
const studentNav = [
  rankingItem,
  dashboardItem,
  examItem2,
  faqItem,
  profileItem,
];
const teacherNav = [dashboardItem, examItem, rankingItem, profileItem];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget?> _pages = List.filled(5, null);

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final theme = Theme.of(context);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final navItems = user.role == 'ADMIN'
        ? adminNav
        : (user.role == 'TEACHER' ? teacherNav : studentNav);

    if (_pages[_currentIndex] == null) {
      _pages[_currentIndex] = navItems[_currentIndex].page;
    }

    return Scaffold(
      body: Stack(
        children: navItems.asMap().entries.map((entry) {
          int index = entry.key;
          return Offstage(
            offstage: _currentIndex != index,
            child: _pages[index] ?? const SizedBox(),
          );
        }).toList(),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: theme.colorScheme.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: navItems.asMap().entries.map((entry) {
            int index = entry.key;
            NavItem item = entry.value;
            bool isSelected = _currentIndex == index;

            return Expanded(
              child: InkWell(
                onTap: () => setState(() => _currentIndex = index),
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          child: Icon(
                            item.icon,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                            size: isSelected ? 26.sp : 20.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/pages/dashboard_page.dart';
import 'package:frontend/pages/faq_page.dart';
import 'package:frontend/pages/leaderboard_page.dart';
import 'package:frontend/pages/profile_page.dart';
import 'package:frontend/services/user_service.dart';
import '../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  UserModel? _user;

  List<Widget> _pages(String role) {
    if (role == 'STUDENT') {
      return const [
        DashboardPage(),
        LeaderboardPage(),
        FaqPage(),
        ProfilePage(),
      ];
    } else if (role == 'TEACHER') {
      return const [
        DashboardPage(),
        LeaderboardPage(),
        FaqPage(),
        ProfilePage(),
      ];
    } else {
      return const [
        DashboardPage(),
        LeaderboardPage(),
        FaqPage(),
        ProfilePage(),
      ];
    }
  }

  Future<void> _loadUser() async {
    final user = await UserService().getUser();
    setState(() {
      _user = user;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages(_user!.role)),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey.shade500,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedFontSize: 12,
        unselectedFontSize: 11,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_rounded),
            label: 'BXH',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline_rounded),
            label: 'Faq',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

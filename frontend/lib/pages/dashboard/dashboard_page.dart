import 'package:flutter/material.dart';
import 'widgets/greeting_section.dart';
import 'widgets/search_bar.dart';
import 'widgets/action_card.dart';
import 'widgets/category_section.dart';
import 'widgets/recent_section.dart';

class DashboardPage extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GreetingSection(username: "Trường"),
              SizedBox(height: 16),
              SearchBarWidget(),
              SizedBox(height: 16),
              ActionCard(),
              SizedBox(height: 20),
              CategorySection(),
              SizedBox(height: 24),
              RecentSection(),
            ],
          ),
        ),
      ),
    );
  }
}

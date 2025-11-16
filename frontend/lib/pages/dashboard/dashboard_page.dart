import 'package:flutter/material.dart';
import 'widgets/greeting_section.dart';
import 'widgets/search_bar.dart';
import 'widgets/action_card.dart';
import 'widgets/category_section.dart';
import 'widgets/recent_section.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: GreetingSection(username: "Phuc"),
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SearchBarWidget(),
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ActionCard(),
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: CategorySection(),
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: RecentSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

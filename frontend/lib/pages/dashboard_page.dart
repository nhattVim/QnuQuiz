import 'package:flutter/material.dart';
import 'package:frontend/widgets/dashboard/action_card.dart';
import 'package:frontend/widgets/dashboard/category_section.dart';
import 'package:frontend/widgets/dashboard/greeting_section.dart';
import 'package:frontend/widgets/dashboard/recent_section.dart';
import 'package:frontend/widgets/dashboard/search_bar.dart';

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

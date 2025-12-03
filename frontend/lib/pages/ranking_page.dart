import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/models/ranking_model.dart';
import 'package:frontend/services/analytics_service.dart';
import 'package:frontend/widgets/ranking/custom_sliding_control.dart';
import 'package:frontend/widgets/ranking/ranking_list.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  final _analyticsService = AnalyticsService();
  bool isWeeklySelected = true;
  late Future<List<RankingModel>> _rankingFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _rankingFuture = isWeeklySelected
          ? _analyticsService.getRankingAllThisWeek()
          : _analyticsService.getRankingAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              Text(
                "Bảng xếp hạng",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 12.h),

              CustomSlidingSegmentedControl(
                isLeftSelected: isWeeklySelected,
                leftText: "Tuần này",
                rightText: "Tất cả",
                onChanged: (isLeft) {
                  if (isWeeklySelected != isLeft) {
                    isWeeklySelected = isLeft;
                    _loadData();
                  }
                },
              ),

              SizedBox(height: 24.h),

              Expanded(
                child: RankingList(
                  rankingFuture: _rankingFuture,
                  onRefresh: _loadData,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

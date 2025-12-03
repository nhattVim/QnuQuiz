import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/models/ranking_model.dart';
import 'package:frontend/providers/service_providers.dart';
import 'package:frontend/widgets/ranking/custom_sliding_control.dart';
import 'package:frontend/widgets/ranking/ranking_list.dart';

class RankingPage extends ConsumerStatefulWidget {
  const RankingPage({super.key});

  @override
  ConsumerState<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends ConsumerState<RankingPage> {
  bool isWeeklySelected = true;
  late Future<List<RankingModel>> _rankingFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final analyticsService = ref.read(analyticsServiceProvider);
    setState(() {
      _rankingFuture = isWeeklySelected
          ? analyticsService.getRankingAllThisWeek()
          : analyticsService.getRankingAll();
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

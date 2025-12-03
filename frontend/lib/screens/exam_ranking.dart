import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/models/ranking_model.dart';
import 'package:frontend/services/analytics_service.dart';
import 'package:frontend/widgets/ranking/ranking_list.dart';

class ExamRanking extends StatelessWidget {
  final int id;
  final AnalyticsService _analyticsService = AnalyticsService();
  late final Future<List<RankingModel>> _rankingFuture;

  ExamRanking({super.key, required this.id}) {
    _rankingFuture = _analyticsService.getRankingByExamId(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BXH")),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: RankingList(rankingFuture: _rankingFuture, onRefresh: () {}),
        ),
      ),
    );
  }
}

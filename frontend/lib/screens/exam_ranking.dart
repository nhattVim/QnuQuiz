import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/models/ranking_model.dart';
import 'package:frontend/providers/service_providers.dart';
import 'package:frontend/widgets/ranking/ranking_list.dart';

class ExamRanking extends ConsumerStatefulWidget {
  final int id;

  const ExamRanking({super.key, required this.id});

  @override
  ConsumerState<ExamRanking> createState() => _ExamRankingState();
}

class _ExamRankingState extends ConsumerState<ExamRanking> {
  late Future<List<RankingModel>> _rankingFuture;

  @override
  void initState() {
    super.initState();
    _rankingFuture = ref
        .read(analyticsServiceProvider)
        .getRankingByExamId(widget.id);
  }

  Future<void> _refreshData() async {
    setState(() {
      _rankingFuture = ref
          .read(analyticsServiceProvider)
          .getRankingByExamId(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BXH")),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: RankingList(
            rankingFuture: _rankingFuture,
            onRefresh: _refreshData,
          ),
        ),
      ),
    );
  }
}

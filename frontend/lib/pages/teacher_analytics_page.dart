import 'package:flutter/material.dart';
import 'package:frontend/models/analytics/exam_analytics_model.dart';
import 'package:frontend/services/analytics_service.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/widgets/analytics/class_performance_tab.dart';
import 'package:frontend/widgets/analytics/overview_tab.dart';
import 'package:frontend/widgets/analytics/question_analysis_tab.dart';
import 'package:frontend/widgets/analytics/score_distribution_tab.dart';
import 'package:frontend/widgets/analytics/student_attempts_tab.dart';

class TeacherAnalyticsPage extends StatefulWidget {
  const TeacherAnalyticsPage({super.key});

  @override
  State<TeacherAnalyticsPage> createState() => _TeacherAnalyticsPageState();
}

class _TeacherAnalyticsPageState extends State<TeacherAnalyticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AnalyticsService _analyticsService = AnalyticsService();

  Future<List<ExamAnalytics>>? _examAnalyticsFuture;
  String? _teacherId;

  @override
  Widget build(BuildContext context) {
    if (_examAnalyticsFuture == null || _teacherId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thống kê & Báo cáo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Tổng quan'),
            Tab(text: 'Lớp học'),
            Tab(text: 'Phổ điểm'),
            Tab(text: 'Lượt làm bài'),
            Tab(text: 'Câu hỏi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          OverviewTab(future: _examAnalyticsFuture!),
          ClassPerformanceTab(
            examFuture: _examAnalyticsFuture!,
            service: _analyticsService,
          ),
          ScoreDistributionTab(
            future: _analyticsService.getScoreDistribution(_teacherId!),
          ),
          StudentAttemptsTab(
            examFuture: _examAnalyticsFuture!,
            service: _analyticsService,
          ),
          QuestionAnalysisTab(
            examFuture: _examAnalyticsFuture!,
            service: _analyticsService,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadUserAndData();
  }

  Future<void> _loadUserAndData() async {
    final user = await UserService().getUser();
    if (user == null) return;

    if (!mounted) return;

    setState(() {
      _teacherId = user.id;
      _examAnalyticsFuture = _analyticsService.getExamAnalytics(_teacherId!);
    });
  }
}

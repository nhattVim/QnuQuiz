import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/models/analytics/exam_analytics_model.dart';
import 'package:frontend/models/analytics/score_distribution_model.dart';
import 'package:frontend/models/teacher_model.dart';
import 'package:frontend/services/analytics_service.dart';
import 'package:frontend/services/teacher_service.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final TeacherService _teacherService = TeacherService();
  final AnalyticsService _analyticsService = AnalyticsService();

  late Future<List<TeacherModel>> _teachersFuture;
  final Map<String, List<ExamAnalytics>> _examAnalytics = {};
  final Map<String, List<ScoreDistribution>> _scoreDistributions = {};

  @override
  void initState() {
    super.initState();
    _teachersFuture = _teacherService.getAllTeachers();
    _teachersFuture.then((teachers) {
      for (var teacher in teachers) {
        _analyticsService.getExamAnalytics(teacher.id.toString()).then((analytics) {
          if (mounted) {
            setState(() {
              _examAnalytics[teacher.id.toString()] = analytics;
            });
          }
        });
        _analyticsService.getScoreDistribution(teacher.id.toString()).then((distributions) {
          if (mounted) {
            setState(() {
              _scoreDistributions[teacher.id.toString()] = distributions;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: FutureBuilder<List<TeacherModel>>(
        future: _teachersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No teachers found.'));
          }

          final teachers = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildExamsPerTeacherChart(teachers),
              const SizedBox(height: 32),
              ...teachers.map((teacher) => _buildScoreDistributionChart(teacher)).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExamsPerTeacherChart(List<TeacherModel> teachers) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Number of Exams per Teacher',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (_examAnalytics.values.isNotEmpty
                          ? _examAnalytics.values
                              .map((e) => e.length)
                              .reduce((a, b) => a > b ? a : b)
                          : 0)
                      .toDouble() +
                      5,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < teachers.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(teachers[index].fullName ?? ''),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 40,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: teachers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final teacher = entry.value;
                    final analytics = _examAnalytics[teacher.id.toString()];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: analytics?.length.toDouble() ?? 0,
                          width: 16,
                          color: Colors.blue,
                        )
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreDistributionChart(TeacherModel teacher) {
    final distribution = _scoreDistributions[teacher.id.toString()];
    if (distribution == null || distribution.isEmpty) {
      return const SizedBox.shrink();
    }
    final scoreDist = distribution.first;
    final sections = [
      PieChartSectionData(
        color: Colors.green,
        value: scoreDist.excellentCount.toDouble(),
        title: 'Excellent\n(${scoreDist.excellentCount})',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.blue,
        value: scoreDist.goodCount.toDouble(),
        title: 'Good\n(${scoreDist.goodCount})',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: scoreDist.averageCount.toDouble(),
        title: 'Average\n(${scoreDist.averageCount})',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: scoreDist.failCount.toDouble(),
        title: 'Fail\n(${scoreDist.failCount})',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score Distribution for ${teacher.fullName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: sections,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

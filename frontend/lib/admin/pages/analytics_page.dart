import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/analytics/admin_exam_analytics_model.dart';
import 'package:frontend/models/analytics/admin_question_analytics_model.dart';
import 'package:frontend/models/analytics/score_distribution_model.dart';
import 'package:frontend/models/analytics/user_analytics_model.dart';
import 'package:frontend/models/teacher_model.dart';
import 'package:frontend/providers/service_providers.dart';
import 'package:frontend/services/analytics_service.dart';
import 'package:frontend/services/teacher_service.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  late Future<UserAnalyticsModel> _userAnalyticsFuture;
  late Future<AdminExamAnalyticsModel> _adminExamAnalyticsFuture;
  late Future<AdminQuestionAnalyticsModel> _adminQuestionAnalyticsFuture;
  late Future<List<dynamic>> _summaryFuture;
  late Future<List<_TeacherAnalyticsData>> _teacherAnalyticsFuture;

  @override
  void initState() {
    super.initState();
    final analyticsService = ref.read(analyticsServiceProvider);
    final teacherService = ref.read(teacherServiceProvider);

    _fetchAdminAnalytics(analyticsService);
    _teacherAnalyticsFuture =
        _fetchTeacherAnalytics(teacherService, analyticsService);
  }

  void _fetchAdminAnalytics(AnalyticsService analyticsService) {
    _userAnalyticsFuture = analyticsService.getUserAnalytics();
    _adminExamAnalyticsFuture = analyticsService.getAdminExamAnalytics();
    _adminQuestionAnalyticsFuture =
        analyticsService.getAdminQuestionAnalytics();
    _summaryFuture = Future.wait([
      _userAnalyticsFuture,
      _adminExamAnalyticsFuture,
      _adminQuestionAnalyticsFuture,
    ]);
  }

  Future<List<_TeacherAnalyticsData>> _fetchTeacherAnalytics(
    TeacherService teacherService,
    AnalyticsService analyticsService,
  ) async {
    final teachers = await teacherService.getAllTeachers();
    final List<_TeacherAnalyticsData> results = [];

    for (final teacher in teachers) {
      final teacherUserId = teacher.userId;

      if (teacherUserId == null) {
        results.add(
          _TeacherAnalyticsData(
            teacher: teacher,
            examCount: 0,
            scoreDistribution: null,
          ),
        );
        continue;
      }

      try {
        final examAnalytics =
            await analyticsService.getExamAnalytics(teacherUserId);
        final scoreDistributions =
            await analyticsService.getScoreDistribution(teacherUserId);
        results.add(
          _TeacherAnalyticsData(
            teacher: teacher,
            examCount: examAnalytics.length,
            scoreDistribution:
                scoreDistributions.isNotEmpty ? scoreDistributions.first : null,
          ),
        );
      } catch (e) {
        debugPrint(
          'Failed to fetch analytics for teacher ${teacher.id}: $e',
        );
        results.add(
          _TeacherAnalyticsData(
            teacher: teacher,
            examCount: 0,
            scoreDistribution: null,
          ),
        );
      }
    }

    return results;
  }

  Widget _buildSummaryGrid() {
    return FutureBuilder<List<dynamic>>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingChartCard('Loading key metrics');
        } else if (snapshot.hasError) {
          return _buildPlaceholderCard(
            'Key metrics',
            message: 'Failed to load overview: ${snapshot.error}',
          );
        } else if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;
        final user = data[0] as UserAnalyticsModel;
        final exam = data[1] as AdminExamAnalyticsModel;
        final question = data[2] as AdminQuestionAnalyticsModel;
        final double activePercent =
            user.totalUsers == 0 ? 0 : user.activeUsers / user.totalUsers;

        final metrics = [
          _MetricData(
            label: 'Total Users',
            value: user.totalUsers.toString(),
            trend: '+${user.newUsersThisMonth} new this month',
            icon: Icons.people_alt_outlined,
            color: Colors.indigo,
          ),
          _MetricData(
            label: 'Active Users',
            value: user.activeUsers.toString(),
            trend: '${(activePercent * 100).toStringAsFixed(1)}% active',
            icon: Icons.speed,
            color: Colors.teal,
          ),
          _MetricData(
            label: 'Total Exams',
            value: exam.totalExams.toString(),
            trend: '${exam.activeExams} active right now',
            icon: Icons.assignment,
            color: Colors.deepPurple,
          ),
          _MetricData(
            label: 'Question Bank',
            value: question.totalQuestions.toString(),
            trend:
                '${question.averageOptionsPerQuestion.toStringAsFixed(1)} options / question',
            icon: Icons.quiz_outlined,
            color: Colors.orange,
          ),
        ];

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: 240,
                  child: _SummaryMetricCard(data: metric),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildUserRoleDistributionCard() {
    return FutureBuilder<UserAnalyticsModel>(
      future: _userAnalyticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingChartCard('User role distribution');
        } else if (snapshot.hasError) {
          return _buildPlaceholderCard(
            'User role distribution',
            message: 'Failed to load: ${snapshot.error}',
          );
        } else if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;
        final colorScheme = Theme.of(context).colorScheme;
        final slices = [
          _ChartSlice(
            label: 'Students',
            value: data.studentsCount.toDouble(),
            color: colorScheme.primary,
          ),
          _ChartSlice(
            label: 'Teachers',
            value: data.teachersCount.toDouble(),
            color: colorScheme.secondary,
          ),
          _ChartSlice(
            label: 'Admins',
            value: data.adminCount.toDouble(),
            color: colorScheme.tertiary,
          ),
        ];
        final total = slices.fold<double>(0, (sum, slice) => sum + slice.value);
        if (total == 0) {
          return _buildPlaceholderCard(
            'User role distribution',
            message: 'No users available yet.',
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'User role distribution',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 260,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 60,
                      sections: slices.map((slice) {
                        final percent =
                            ((slice.value / total) * 100).toStringAsFixed(0);
                        return PieChartSectionData(
                          color: slice.color,
                          value: slice.value,
                          title: '$percent%',
                          radius: 80,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: slices
                      .map(
                        (slice) => _ChartLegend(
                          color: slice.color,
                          label:
                              '${slice.label} (${slice.value.toInt().toString()})',
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExamStatusChart() {
    return FutureBuilder<AdminExamAnalyticsModel>(
      future: _adminExamAnalyticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingChartCard('Exam status');
        } else if (snapshot.hasError) {
          return _buildPlaceholderCard(
            'Exam status',
            message: 'Failed to load: ${snapshot.error}',
          );
        } else if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final analytics = snapshot.data!;
        final inactive = (analytics.totalExams - analytics.activeExams).clamp(
          0,
          analytics.totalExams,
        );
        final slices = [
          _ChartSlice(
            label: 'Active',
            value: analytics.activeExams.toDouble(),
            color: Colors.green,
          ),
          _ChartSlice(
            label: 'Inactive',
            value: inactive.toDouble(),
            color: Colors.grey.shade400,
          ),
        ];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Exam status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 70,
                          sections: slices
                              .map(
                                (slice) => PieChartSectionData(
                                  color: slice.color,
                                  value: slice.value,
                                  radius: 80,
                                  title: '',
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            analytics.totalExams.toString(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Total exams'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: slices
                      .map(
                        (slice) => _ChartLegend(
                          color: slice.color,
                          label:
                              '${slice.label} (${slice.value.toInt().toString()})',
                        ),
                      )
                      .toList(),
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Avg attempts/exam: ${analytics.averageAttemptsPerExam.toStringAsFixed(1)}',
                    ),
                    Text(
                      'Avg score: ${analytics.overallAverageScore.toStringAsFixed(1)}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionTypeChart() {
    return FutureBuilder<AdminQuestionAnalyticsModel>(
      future: _adminQuestionAnalyticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingChartCard('Question types');
        } else if (snapshot.hasError) {
          return _buildPlaceholderCard(
            'Question types',
            message: 'Failed to load: ${snapshot.error}',
          );
        } else if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final analytics = snapshot.data!;
        final double maxValue = math.max(
          analytics.multipleChoiceQuestions.toDouble(),
          analytics.trueFalseQuestions.toDouble(),
        );
        final double maxY = maxValue == 0 ? 1 : maxValue * 1.2;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Question types',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 260,
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
                      barTouchData: BarTouchData(enabled: false),
                      gridData:
                          const FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            interval: math.max(1, maxY / 4),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text('Multiple choice'),
                                  );
                                case 1:
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text('True / False'),
                                  );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY:
                                  analytics.multipleChoiceQuestions.toDouble(),
                              width: 28,
                              borderRadius: BorderRadius.circular(6),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.deepPurple.shade200,
                                  Colors.deepPurple,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: analytics.trueFalseQuestions.toDouble(),
                              width: 28,
                              borderRadius: BorderRadius.circular(6),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade200,
                                  Colors.orange,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Avg options/question: ${analytics.averageOptionsPerQuestion.toStringAsFixed(1)}',
                ),
                Text(
                  'Avg usage in exams: ${analytics.averageUsageInExams.toStringAsFixed(1)}',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingChartCard(String title) {
    return Card(
      child: SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderCard(String title, {String? message}) {
    return Card(
      child: SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(message ?? 'No data available'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 1100;
        final double contentWidth = constraints.maxWidth - 32;
        final double tileWidth =
            isWide ? (contentWidth - 16) / 2 : contentWidth;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Admin Overview',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSummaryGrid(),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: tileWidth,
                    child: _buildUserRoleDistributionCard(),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: _buildExamStatusChart(),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: _buildQuestionTypeChart(),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Detailed Analytics',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildUserAnalyticsCard(),
              const SizedBox(height: 16),
              _buildExamAnalyticsCard(),
              const SizedBox(height: 16),
              _buildQuestionAnalyticsCard(),
              const SizedBox(height: 32),
              const Text(
                'Teacher-Specific Analytics',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
          FutureBuilder<List<_TeacherAnalyticsData>>(
            future: _teacherAnalyticsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No teachers found.'));
                  }

              final analyticsData = snapshot.data!;
              final hasExamData =
                  analyticsData.any((data) => data.examCount > 0);
              final scoreCards = analyticsData
                  .where((data) => data.scoreDistribution != null)
                  .toList();

                  return Column(
                    children: [
                  if (hasExamData) ...[
                    _buildExamsPerTeacherChart(analyticsData),
                    const SizedBox(height: 32),
                  ] else
                    _buildPlaceholderCard(
                      'Number of Exams per Teacher',
                      message:
                          'No teacher-created exams found. Encourage teachers to create exams to see this chart.',
                    ),
                  if (scoreCards.isNotEmpty)
                    ...scoreCards.map(_buildScoreDistributionChart)
                  else
                    _buildPlaceholderCard(
                      'Score distribution',
                      message:
                          'No score distribution data is available for teachers yet.',
                    ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserAnalyticsCard() {
    return FutureBuilder<UserAnalyticsModel>(
      future: _userAnalyticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error loading user analytics: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return const Text('No user analytics data.');
        }
        final analytics = snapshot.data!;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'User Statistics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Text('Total Users: ${analytics.totalUsers}'),
                Text('New Users This Month: ${analytics.newUsersThisMonth}'),
                Text('Active Users: ${analytics.activeUsers}'),
                Text('Students: ${analytics.studentsCount}'),
                Text('Teachers: ${analytics.teachersCount}'),
                Text('Admins: ${analytics.adminCount}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExamAnalyticsCard() {
    return FutureBuilder<AdminExamAnalyticsModel>(
      future: _adminExamAnalyticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error loading exam analytics: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return const Text('No exam analytics data.');
        }
        final analytics = snapshot.data!;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Exam Statistics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Text('Total Exams: ${analytics.totalExams}'),
                Text('Active Exams: ${analytics.activeExams}'),
                Text(
                  'Avg. Questions per Exam: ${analytics.averageQuestionsPerExam.toStringAsFixed(2)}',
                ),
                Text(
                  'Avg. Attempts per Exam: ${analytics.averageAttemptsPerExam.toStringAsFixed(2)}',
                ),
                Text(
                  'Overall Avg. Score: ${analytics.overallAverageScore.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionAnalyticsCard() {
    return FutureBuilder<AdminQuestionAnalyticsModel>(
      future: _adminQuestionAnalyticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error loading question analytics: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return const Text('No question analytics data.');
        }
        final analytics = snapshot.data!;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Question Statistics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Text('Total Questions: ${analytics.totalQuestions}'),
                Text(
                  'Multiple Choice Questions: ${analytics.multipleChoiceQuestions}',
                ),
                Text('True/False Questions: ${analytics.trueFalseQuestions}'),
                Text(
                  'Avg. Options per Question: ${analytics.averageOptionsPerQuestion.toStringAsFixed(2)}',
                ),
                Text(
                  'Avg. Usage in Exams: ${analytics.averageUsageInExams.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExamsPerTeacherChart(
    List<_TeacherAnalyticsData> teacherAnalytics,
  ) {
    if (teacherAnalytics.isEmpty) {
      return _buildPlaceholderCard(
        'Number of Exams per Teacher',
        message: 'No teachers available to visualize.',
      );
    }
    final maxExamCount = teacherAnalytics
        .map((data) => data.examCount)
        .fold<int>(0, (prev, element) => math.max(prev, element));

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
                  maxY:
                      maxExamCount == 0 ? 1 : maxExamCount.toDouble() + 1,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < teacherAnalytics.length) {
                            final teacher = teacherAnalytics[index].teacher;
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                teacher.fullName ??
                                    teacher.username ??
                                    'Teacher ${index + 1}',
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 40,
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: teacherAnalytics.asMap().entries.map((entry) {
                    final index = entry.key;
                    final analytics = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: analytics.examCount.toDouble(),
                          width: 16,
                          color: Colors.blue,
                        ),
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

  Widget _buildScoreDistributionChart(_TeacherAnalyticsData data) {
    final scoreDist = data.scoreDistribution;
    if (scoreDist == null) {
      return const SizedBox.shrink();
    }

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
              'Score Distribution for ${data.teacher.fullName ?? data.teacher.username ?? 'Teacher ${data.teacher.id}'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: PieChart(PieChartData(sections: sections)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeacherAnalyticsData {
  const _TeacherAnalyticsData({
    required this.teacher,
    required this.examCount,
    required this.scoreDistribution,
  });

  final TeacherModel teacher;
  final int examCount;
  final ScoreDistribution? scoreDistribution;
}

class _MetricData {
  const _MetricData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
  });

  final String label;
  final String value;
  final String? trend;
  final IconData icon;
  final Color color;
}

class _SummaryMetricCard extends StatelessWidget {
  const _SummaryMetricCard({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(data.icon, color: data.color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.label,
                    style: theme.textTheme.labelMedium,
                  ),
                  Text(
                    data.value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (data.trend != null)
                    Text(
                      data.trend!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartSlice {
  const _ChartSlice({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

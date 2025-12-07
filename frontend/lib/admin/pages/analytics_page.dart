import 'dart:io';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
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

  Future<void> _onExportUsersCsv() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final analyticsService = ref.read(analyticsServiceProvider);
      final bytes = await analyticsService.downloadUserAnalyticsCsv();
      
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Lưu file CSV thống kê người dùng',
        fileName: 'user_analytics_${DateTime.now().millisecondsSinceEpoch}.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      
      if (result != null) {
        final file = File(result);
        await file.writeAsBytes(bytes);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Đã xuất file CSV thống kê người dùng thành công.'),
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Lỗi export thống kê người dùng: $e')),
      );
    }
  }

  Future<void> _onExportExamsCsv() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final analyticsService = ref.read(analyticsServiceProvider);
      final bytes = await analyticsService.downloadExamAnalyticsCsv();
      
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Lưu file CSV thống kê bài thi',
        fileName: 'exam_analytics_${DateTime.now().millisecondsSinceEpoch}.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      
      if (result != null) {
        final file = File(result);
        await file.writeAsBytes(bytes);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Đã xuất file CSV thống kê bài thi thành công.'),
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Lỗi export thống kê bài thi: $e')),
      );
    }
  }

  Future<void> _onExportQuestionsCsv() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final analyticsService = ref.read(analyticsServiceProvider);
      final bytes = await analyticsService.downloadQuestionAnalyticsCsv();
      
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Lưu file CSV thống kê câu hỏi',
        fileName: 'question_analytics_${DateTime.now().millisecondsSinceEpoch}.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      
      if (result != null) {
        final file = File(result);
        await file.writeAsBytes(bytes);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Đã xuất file CSV thống kê câu hỏi thành công.'),
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Lỗi export thống kê câu hỏi: $e')),
      );
    }
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

        final theme = Theme.of(context);
        final scheme = theme.colorScheme;

        final metrics = [
          _MetricData(
            label: 'Total Users',
            value: user.totalUsers.toString(),
            trend: '+${user.newUsersThisMonth} new this month',
            icon: Icons.people_alt_outlined,
            color: scheme.primary,
          ),
          _MetricData(
            label: 'Active Users',
            value: user.activeUsers.toString(),
            trend: '${(activePercent * 100).toStringAsFixed(1)}% active',
            icon: Icons.speed,
            color: scheme.secondary,
          ),
          _MetricData(
            label: 'Total Exams',
            value: exam.totalExams.toString(),
            trend: '${exam.activeExams} active right now',
            icon: Icons.assignment,
            color: scheme.tertiary,
          ),
          _MetricData(
            label: 'Question Bank',
            value: question.totalQuestions.toString(),
            trend:
                '${question.averageOptionsPerQuestion.toStringAsFixed(1)} options / question',
            icon: Icons.quiz_outlined,
            color: scheme.secondaryContainer,
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
                Text(
                  'User role distribution',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                          sections: slices.map((slice) {
                            final percent =
                                ((slice.value / total) * 100).toStringAsFixed(0);
                            return PieChartSectionData(
                              color: slice.color,
                              value: slice.value,
                              radius: 80,
                              title: '',
                            );
                          }).toList(),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            data.totalUsers.toString(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Total users'),
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
                      'Total users: ${data.totalUsers}',
                    ),
                    Text(
                      'New this month: ${data.newUsersThisMonth}',
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
        final scheme = Theme.of(context).colorScheme;
        final inactive = (analytics.totalExams - analytics.activeExams).clamp(
          0,
          analytics.totalExams,
        );
        final slices = [
          _ChartSlice(
            label: 'Active',
            value: analytics.activeExams.toDouble(),
            color: scheme.secondary,
          ),
          _ChartSlice(
            label: 'Inactive',
            value: inactive.toDouble(),
            color: scheme.outlineVariant,
          ),
        ];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exam status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Admin Overview',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _onExportUsersCsv,
                        icon: const Icon(Icons.download),
                        label: const Text('Export users CSV'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _onExportExamsCsv,
                        icon: const Icon(Icons.download),
                        label: const Text('Export exams CSV'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _onExportQuestionsCsv,
                        icon: const Icon(Icons.download),
                        label: const Text('Export questions CSV'),
                      ),
                    ],
                  ),
                ],
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

                  return Column(
                    children: [
                  if (hasExamData) ...[
                    _buildExamsPerTeacherChart(analyticsData),
                  ] else
                    _buildPlaceholderCard(
                      'Number of Exams per Teacher',
                      message:
                          'No teacher-created exams found. Encourage teachers to create exams to see this chart.',
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
        final scheme = Theme.of(context).colorScheme;
        final slices = [
          _ChartSlice(
            label: 'Multiple Choice',
            value: analytics.multipleChoiceQuestions.toDouble(),
            color: scheme.primary,
          ),
          _ChartSlice(
            label: 'True/False',
            value: analytics.trueFalseQuestions.toDouble(),
            color: scheme.secondary,
          ),
        ];
        final total = slices.fold<double>(0, (sum, slice) => sum + slice.value);
        if (total == 0) {
          return _buildPlaceholderCard(
            'Question types',
            message: 'No questions available yet.',
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question types',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                          sections: slices.map((slice) {
                            final percent =
                                ((slice.value / total) * 100).toStringAsFixed(0);
                            return PieChartSectionData(
                              color: slice.color,
                              value: slice.value,
                              radius: 80,
                              title: '',
                            );
                          }).toList(),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            analytics.totalQuestions.toString(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Total questions'),
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
                      'Avg options/question: ${analytics.averageOptionsPerQuestion.toStringAsFixed(1)}',
                    ),
                    Text(
                      'Avg usage in exams: ${analytics.averageUsageInExams.toStringAsFixed(1)}',
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

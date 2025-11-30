import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
// import 'package:frontend/models/class_performance_model.dart';
// import 'package:frontend/models/exam_analytics_model.dart';
import 'package:frontend/models/analytics/class_performance_model.dart';
import 'package:frontend/models/analytics/exam_analytics_model.dart';
import 'package:frontend/services/analytics_service.dart';
import 'package:frontend/widgets/analytics/async_data_builder.dart';
import 'package:frontend/widgets/analytics/exam_selector_layout.dart';

class ClassPerformanceTab extends StatefulWidget {
  final Future<List<ExamAnalytics>> examFuture;
  final AnalyticsService service;
  const ClassPerformanceTab({
    super.key,
    required this.examFuture,
    required this.service,
  });

  @override
  State<ClassPerformanceTab> createState() => _ClassPerformanceTabState();
}

class _ClassPerformanceTabState extends State<ClassPerformanceTab> {
  ExamAnalytics? _selectedExam;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ExamSelectorLayout(
      examFuture: widget.examFuture,
      onExamSelected: (exam) => setState(() => _selectedExam = exam),
      selectedExam: _selectedExam,
      child: _selectedExam == null
          ? const SizedBox.shrink()
          : AsyncDataBuilder<List<ClassPerformance>>(
              future: widget.service.getClassPerformance(
                _selectedExam!.examId.toInt(),
              ),
              builder: (data) {
                double maxY =
                    (data.map((e) => e.avgScorePerClass).reduce(max) * 1.2)
                        .ceilToDouble();

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Column(
                    children: [
                      Text(
                        'Điểm trung bình theo lớp',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 40),
                      Expanded(
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: maxY,
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (_) =>
                                    colorScheme.inverseSurface,
                                getTooltipItem:
                                    (group, groupIndex, rod, rodIndex) {
                                      return BarTooltipItem(
                                        '${data[groupIndex].className}\n',
                                        TextStyle(
                                          color: colorScheme.onInverseSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        children: [
                                          TextSpan(text: rod.toY.toString()),
                                        ],
                                      );
                                    },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() < data.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Text(
                                          data[value.toInt()].className,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: data.asMap().entries.map((e) {
                              return BarChartGroupData(
                                x: e.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: e.value.avgScorePerClass,
                                    color: colorScheme.primary,
                                    width: 16,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

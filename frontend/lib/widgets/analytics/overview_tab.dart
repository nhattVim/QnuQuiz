import 'package:flutter/material.dart';
import 'package:frontend/models/analytics/exam_analytics_model.dart';
import 'package:frontend/widgets/analytics/async_data_builder.dart';

class OverviewTab extends StatelessWidget {
  final Future<List<ExamAnalytics>> future;
  const OverviewTab({super.key, required this.future});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AsyncDataBuilder<List<ExamAnalytics>>(
      future: future,
      builder: (data) {
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final exam = data[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            exam.examTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'TB: ${exam.avgScore}',
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatItem(
                          label: 'Lượt làm',
                          value: '${exam.totalAttempts}',
                          icon: Icons.people,
                        ),
                        _StatItem(
                          label: 'Đã nộp',
                          value: '${exam.totalSubmitted}',
                          icon: Icons.check_circle,
                        ),
                        _StatItem(
                          label: 'Cao nhất',
                          value: '${exam.maxScore}',
                          icon: Icons.arrow_upward,
                          color: Colors.green,
                        ),
                        _StatItem(
                          label: 'Thấp nhất',
                          value: '${exam.minScore}',
                          icon: Icons.arrow_downward,
                          color: colorScheme.error,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayColor = color ?? theme.colorScheme.onSurfaceVariant;

    return Column(
      children: [
        Icon(icon, size: 20, color: displayColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

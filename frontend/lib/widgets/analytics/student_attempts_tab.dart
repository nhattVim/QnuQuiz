import 'package:flutter/material.dart';
import 'package:frontend/models/analytics/exam_analytics_model.dart';
import 'package:frontend/models/analytics/student_attempt_model.dart';
import 'package:frontend/services/analytics_service.dart';
import 'package:frontend/widgets/analytics/async_data_builder.dart';
import 'package:frontend/widgets/analytics/exam_selector_layout.dart';

class StudentAttemptsTab extends StatefulWidget {
  final Future<List<ExamAnalytics>> examFuture;
  final AnalyticsService service;
  const StudentAttemptsTab({
    super.key,
    required this.examFuture,
    required this.service,
  });

  @override
  State<StudentAttemptsTab> createState() => _StudentAttemptsTabState();
}

class _StudentAttemptsTabState extends State<StudentAttemptsTab> {
  ExamAnalytics? _selectedExam;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ExamSelectorLayout(
      examFuture: widget.examFuture,
      selectedExam: _selectedExam,
      onExamSelected: (val) => setState(() => _selectedExam = val),
      child: _selectedExam == null
          ? const SizedBox.shrink()
          : AsyncDataBuilder<List<StudentAttempt>>(
              future: widget.service.getStudentAttempts(
                _selectedExam!.examId.toInt(),
              ),
              builder: (data) {
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: data.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = data[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(
                            item.studentCode.substring(
                              item.studentCode.length > 2
                                  ? item.studentCode.length - 2
                                  : 0,
                            ),
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          item.fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${item.studentCode} • ${item.className}\n${item.durationMinutes} phút',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        isThreeLine: true,
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${item.score}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: item.score >= 5
                                    ? Colors.green
                                    : colorScheme.error,
                              ),
                            ),
                            Text(
                              item.submitted ? 'Đã nộp' : 'Chưa nộp',
                              style: TextStyle(
                                fontSize: 10,
                                color: item.submitted
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/models/analytics/exam_analytics_model.dart';
import 'package:frontend/models/analytics/question_analytics_model.dart';
import 'package:frontend/services/analytics_service.dart';
import 'package:frontend/widgets/analytics/async_data_builder.dart';
import 'package:frontend/widgets/analytics/exam_selector_layout.dart';

class QuestionAnalysisTab extends StatefulWidget {
  final Future<List<ExamAnalytics>> examFuture;
  final AnalyticsService service;
  const QuestionAnalysisTab({
    super.key,
    required this.examFuture,
    required this.service,
  });

  @override
  State<QuestionAnalysisTab> createState() => _QuestionAnalysisTabState();
}

class _QuestionAnalysisTabState extends State<QuestionAnalysisTab> {
  ExamAnalytics? _selectedExam;

  @override
  Widget build(BuildContext context) {
    return ExamSelectorLayout(
      examFuture: widget.examFuture,
      selectedExam: _selectedExam,
      onExamSelected: (val) => setState(() => _selectedExam = val),
      child: _selectedExam == null
          ? const SizedBox.shrink()
          : AsyncDataBuilder<List<QuestionAnalytics>>(
              future: widget.service.getQuestionAnalytics(
                _selectedExam!.examId.toInt(),
              ),
              builder: (data) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final q = data[index];
                    final color = q.correctRate >= 80
                        ? Colors.green
                        : (q.correctRate >= 50
                              ? Colors.orange
                              : Theme.of(context).colorScheme.error);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Câu ${index + 1}: ${q.questionContent}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: q.correctRate / 100,
                                minHeight: 8,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                color: color,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Đúng: ${q.correctRate}%',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    _StatusChip(
                                      label: '${q.correctCount}',
                                      icon: Icons.check,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 8),
                                    _StatusChip(
                                      label: '${q.wrongCount}',
                                      icon: Icons.close,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ],
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
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _StatusChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

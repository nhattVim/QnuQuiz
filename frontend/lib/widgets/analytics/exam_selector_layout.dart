import 'package:flutter/material.dart';
import 'package:frontend/models/analytics/exam_analytics_model.dart';

class ExamSelectorLayout extends StatelessWidget {
  final Future<List<ExamAnalytics>> examFuture;
  final ExamAnalytics? selectedExam;
  final Function(ExamAnalytics) onExamSelected;
  final Widget child;

  const ExamSelectorLayout({
    super.key,
    required this.examFuture,
    required this.selectedExam,
    required this.onExamSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ExamAnalytics>>(
      future: examFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final exams = snapshot.data!;
        if (exams.isEmpty) {
          return const Center(child: Text('Không có bài kiểm tra'));
        }

        if (selectedExam == null && exams.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onExamSelected(exams.first);
          });
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).cardTheme.color ??
                    Theme.of(context).colorScheme.surface,
                boxShadow: [
                  if (Theme.of(context).brightness == Brightness.light)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: DropdownButtonFormField<ExamAnalytics>(
                initialValue: selectedExam ?? exams.first,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Chọn bài kiểm tra',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: exams
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e.examTitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) onExamSelected(val);
                },
              ),
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

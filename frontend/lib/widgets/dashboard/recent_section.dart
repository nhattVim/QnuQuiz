import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exam_history_model.dart';
import 'package:frontend/providers/service_providers.dart';
import 'package:frontend/screens/quiz/quiz_review_screen.dart';
import 'package:frontend/screens/quiz/quiz_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentSection extends ConsumerWidget {
  final List<ExamHistoryModel>? examHistory;
  final bool isLoading;
  final String? errorMessage;

  const RecentSection({
    super.key,
    this.examHistory,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    if (errorMessage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Làm gần đây",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                "Không thể tải lịch sử: $errorMessage",
                style: TextStyle(color: colorScheme.onErrorContainer),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Làm gần đây",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            3,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 150,
                          height: 14,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 60,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 30,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (examHistory == null || examHistory!.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Làm gần đây",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 48,
                    color: colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Chưa có bài thi nào",
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Hãy bắt đầu làm bài thi đầu tiên!",
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.38),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Làm gần đây",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: examHistory!
              .map(
                (history) =>
                    _buildRecentItem(context, ref, history, colorScheme),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildRecentItem(
    BuildContext context,
    WidgetRef ref,
    ExamHistoryModel history,
    ColorScheme colorScheme,
  ) {
    final bool isCompleted = history.isCompleted;
    final String status = isCompleted ? 'Xem lại' : 'Tiếp tục';
    final Color color = isCompleted ? colorScheme.primary : Colors.green;

    // Tính progress nếu có
    final int totalQuestions = history.answers.length;
    final int answeredQuestions = history.answers
        .where((a) => a.selectedOptionId != null)
        .length;
    final String progress = totalQuestions > 0
        ? '$answeredQuestions/$totalQuestions'
        : (history.score != null
              ? '${history.score!.toStringAsFixed(0)}%'
              : '---');

    return GestureDetector(
      onTap: () {
        if (isCompleted) {
          _handleReviewExam(context, ref, history.attemptId);
        } else {
          _handleContinueExam(context, history);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted
                    ? colorScheme.primary.withValues(alpha: 0.2)
                    : Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.menu_book_rounded,
                color: isCompleted ? colorScheme.primary : Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    history.examTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        progress,
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                      if (history.completionDate != null) ...[
                        Text(
                          '  •  ',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _formatDate(history.completionDate!),
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hôm nay';
    } else if (diff.inDays == 1) {
      return 'Hôm qua';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

Future<void> _handleContinueExam(
  BuildContext context,
  ExamHistoryModel history,
) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'quiz_state_${history.attemptId}';

  final savedRemainingSeconds = prefs.getInt('${key}_remainingSeconds');

  if (savedRemainingSeconds == null || savedRemainingSeconds <= 0) {
    final remainingSeconds = history.remainingSeconds;
    if (remainingSeconds > 0) {
      await prefs.setInt('${key}_remainingSeconds', remainingSeconds);
    }
  }

  if (!context.mounted) return;

  // Lấy duration từ examDurationMinutes hoặc fallback
  final int? duration =
      history.examDurationMinutes ?? history.durationMinutes?.toInt();

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => QuizScreen(
        examTitle: history.examTitle,
        totalQuestions: history.answers.isNotEmpty ? history.answers.length : 0,
        examId: history.examId,
        attemptId: history.attemptId,
        durationMinutes: duration,
      ),
    ),
  );
}

Future<void> _handleReviewExam(
  BuildContext context,
  WidgetRef ref,
  int attemptId,
) async {
  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Đang tải dữ liệu...'),
              ],
            ),
          ),
        );
      },
    );

    final examReview = await ref
        .read(examServiceProvider)
        .reviewExamAttempt(attemptId);

    // Đóng loading dialog
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QuizReviewScreen(
            examReview: examReview,
            totalQuestions: examReview.answers.length,
          ),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

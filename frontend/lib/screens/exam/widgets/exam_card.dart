import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:frontend/models/exam_model.dart';
import 'package:frontend/screens/exam/widgets/exam_status_helper.dart';
import 'package:frontend/screens/exam_ranking.dart';
import 'package:frontend/screens/feedback_screen.dart';
import 'package:frontend/utils/datetime_format.dart';

class ExamCard extends StatelessWidget {
  final ExamModel exam;
  final VoidCallback? onPressed;
  final VoidCallback? onReviewPressed;

  const ExamCard({
    super.key,
    required this.exam,
    this.onPressed,
    this.onReviewPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = ExamStatusUI.getColor(exam);
    final statusText = ExamStatusUI.getText(exam);
    final buttonText = ExamStatusUI.getButtonText(exam);
    final buttonTextColor = ExamStatusUI.getButtonTextColor(exam);
    final buttonBgColor = ExamStatusUI.getButtonBgColor(exam, context);
    final buttonEnabled = ExamStatusUI.isButtonEnabled(exam);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.none,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              // LEFT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${exam.durationMinutes ?? 0} phút",
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const SizedBox(width: 2),
                        Icon(Boxicons.bxs_circle, size: 12, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Boxicons.bx_door_open,
                          size: 16,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          exam.startTime != null
                              ? exam.startTime!.toFullString()
                              : "Mở: Chưa xác định",
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.hourglass_bottom,
                          size: 16,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          exam.endTime != null
                              ? exam.endTime!.toFullString()
                              : "Kết thúc: Chưa xác định",
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // RIGHT - Button only
              SizedBox(
                height: 124,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: buttonEnabled
                          ? (buttonText == "Xem lại bài"
                                ? onReviewPressed
                                : onPressed)
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        backgroundColor: buttonBgColor,
                        disabledBackgroundColor:
                            colorScheme.surfaceContainerHighest,
                        side: buttonEnabled
                            ? BorderSide(color: colorScheme.primary)
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: TextStyle(color: buttonTextColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Absolute positioned menu button
          Positioned(
            top: -14,
            right: -8,
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              position: PopupMenuPosition.under,
              offset: const Offset(0, 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              icon: Icon(Icons.more_horiz, color: colorScheme.onSurface),
              onSelected: (value) {
                if (value == 'ranking') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ExamRanking(id: exam.id),
                    ),
                  );
                } else if (value == 'review') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FeedbackScreen(
                        examId: exam.id,
                        examTitle: exam.title,
                      ),
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'ranking',
                  child: Row(
                    children: [
                      Icon(
                        Icons.leaderboard,
                        size: 20,
                        color: colorScheme.onSurface,
                      ),
                      const SizedBox(width: 8),
                      const Text('Xếp hạng'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'review',
                  child: Row(
                    children: [
                      Icon(
                        Icons.rate_review,
                        size: 20,
                        color: colorScheme.onSurface,
                      ),
                      const SizedBox(width: 8),
                      const Text('Đánh giá'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

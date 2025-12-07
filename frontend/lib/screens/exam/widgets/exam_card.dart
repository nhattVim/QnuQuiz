import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/models/exam_model.dart';
import 'package:frontend/screens/exam/widgets/exam_status_helper.dart';
import 'package:frontend/screens/exam_ranking.dart';
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
    final statusColor = ExamStatusUI.getColor(exam);
    final statusText = ExamStatusUI.getText(exam);
    final buttonText = ExamStatusUI.getButtonText(exam);
    final buttonTextColor = ExamStatusUI.getButtonTextColor(exam);
    final buttonBgColor = ExamStatusUI.getButtonBgColor(exam);
    final buttonEnabled = ExamStatusUI.isButtonEnabled(exam);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // LEFT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16),
                    const SizedBox(width: 4),
                    Text("${exam.durationMinutes ?? 0} phút"),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const SizedBox(width: 2),
                    Icon(Boxicons.bxs_circle, size: 12, color: statusColor),
                    const SizedBox(width: 6),
                    Text(statusText),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Boxicons.bx_door_open, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      exam.startTime != null
                          ? exam.startTime!.toFullString()
                          : "Mở: Chưa xác định",
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.hourglass_bottom, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      exam.endTime != null
                          ? exam.endTime!.toFullString()
                          : "Kết thúc: Chưa xác định",
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // RIGHT
          Container(
            height: 124,
            alignment: Alignment.bottomRight,
            child: Column(
              children: [
                InkWell(
                  child: Image.network(
                    "https://cdn-icons-png.flaticon.com/512/983/983865.png",
                    width: 50.w,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ExamRanking(id: exam.id),
                      ),
                    );
                  },
                ),
                const Spacer(),
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
                    disabledBackgroundColor: Colors.grey.shade400,
                    side: buttonEnabled
                        ? const BorderSide(color: Colors.blue)
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
    );
  }
}

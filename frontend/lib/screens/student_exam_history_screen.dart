import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/models/exam_history_model.dart';
import 'package:frontend/screens/quiz/quiz_review_screen.dart';
import 'package:frontend/providers/service_providers.dart';
import 'package:intl/intl.dart';

class StudentExamHistoryScreen extends ConsumerStatefulWidget {
  const StudentExamHistoryScreen({super.key});

  @override
  ConsumerState<StudentExamHistoryScreen> createState() =>
      _StudentExamHistoryScreenState();
}

class _StudentExamHistoryScreenState
    extends ConsumerState<StudentExamHistoryScreen> {
  late Future<List<ExamHistoryModel>> _historyFuture;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lịch sử làm bài thi',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadHistory();
          await _historyFuture;
        },
        child: FutureBuilder<List<ExamHistoryModel>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error.withValues(alpha: 0.7),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Lỗi tải dữ liệu',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      snapshot.error.toString().replaceAll('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton.icon(
                      onPressed: _loadHistory,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 80,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Chưa có lịch sử làm bài',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Bạn chưa hoàn thành bài thi nào',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              );
            }

            final historyList = snapshot.data!;

            return ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: historyList.length,
              separatorBuilder: (_, _) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final history = historyList[index];
                return _buildHistoryCard(history, colorScheme);
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Widget _buildHistoryCard(ExamHistoryModel history, ColorScheme colorScheme) {
    final score = history.score;
    final scoreColor = _getScoreColor(score);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final durationText = history.durationMinutes != null
        ? '${history.durationMinutes} phút'
        : 'N/A';

    return Card(
      elevation: 2,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _handleReviewExam(context, history.attemptId),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colorScheme.surface, scoreColor.withValues(alpha: 0.05)],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Tên chủ đề
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        history.examTitle,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Thông tin chi tiết
                Row(
                  children: [
                    // Điểm số
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.star,
                        label: 'Điểm',
                        value: score != null
                            ? score.toStringAsFixed(1)
                            : 'Chưa chấm',
                        valueColor: scoreColor,
                        iconColor: scoreColor,
                        colorScheme: colorScheme,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Thời gian làm bài
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.timer,
                        label: 'Thời gian',
                        value: durationText,
                        valueColor: colorScheme.primary,
                        iconColor: colorScheme.primary,
                        colorScheme: colorScheme,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Ngày hoàn thành
                if (history.completionDate != null)
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16.sp,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Hoàn thành: ${dateFormat.format(history.completionDate!)}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    required Color iconColor,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: iconColor),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double? score) {
    if (score == null) return Colors.grey;
    if (score >= 8.0) return Colors.green;
    if (score >= 6.5) return Colors.orange;
    if (score >= 5.0) return Colors.amber;
    return Colors.red;
  }

  Future<void> _handleReviewExam(BuildContext context, int attemptId) async {
    try {
      // Hiển thị loading dialog
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

      // Gọi API để lấy dữ liệu review
      final examReview = await ref
          .read(examServiceProvider)
          .reviewExamAttempt(attemptId);

      // Đóng loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Chuyển sang QuizReviewScreen với dữ liệu từ API
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
      // Đóng loading dialog nếu có lỗi
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

  void _loadHistory() {
    setState(() {
      _historyFuture = ref.read(studentServiceProvider).getExamHistory();
    });
  }
}

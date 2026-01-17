import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:frontend/models/exam_model.dart';
import 'package:frontend/screens/exam/widgets/exam_card.dart';
import 'package:frontend/screens/quiz/quiz_screen.dart';
import 'package:frontend/screens/quiz/quiz_review_screen.dart';
import 'package:frontend/screens/student_exam_history_screen.dart';
import 'package:frontend/providers/service_providers.dart'; // Import service providers
import 'package:frontend/utils/vietnamese_helper.dart';

class ExamListScreen extends ConsumerStatefulWidget {
  // Changed to ConsumerStatefulWidget
  final int? categoryId; // Made optional
  final String? searchQuery; // Query tìm kiếm

  const ExamListScreen({super.key, this.categoryId, this.searchQuery});

  @override
  ConsumerState<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends ConsumerState<ExamListScreen> {
  late Future<List<ExamModel>> futureExams;
  late Key _futureBuilderKey;
  // Removed direct instantiation:
  // final ExamService _examService = ExamService();

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  void _loadExams() async {
    final examService = ref.read(
      examServiceProvider,
    ); // Get service from provider

    setState(() {
      // Nếu có searchQuery, lấy tất cả và filter
      if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
        futureExams = examService.getAllExams().then((exams) {
          return exams.where((exam) {
            return VietnameseHelper.containsIgnoreTones(
                  exam.title,
                  widget.searchQuery!,
                ) ||
                VietnameseHelper.containsIgnoreTones(
                  exam.description,
                  widget.searchQuery!,
                );
          }).toList();
        });
      }
      // Nếu có categoryId, lấy theo category
      else if (widget.categoryId != null) {
        futureExams = examService.getExamsByCategory(widget.categoryId!);
      }
      // Ngược lại lấy tất cả
      else {
        futureExams = examService.getAllExams();
      }
      _futureBuilderKey = UniqueKey();
    });
  }

  Future<void> _handleExamPressed(ExamModel exam) async {
    final examService = ref.read(
      examServiceProvider,
    ); // Get service from provider
    try {
      final attempt = await examService.startExam(exam.id);

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizScreen(
            examId: exam.id,
            durationMinutes: exam.durationMinutes,
            attemptId: attempt.id,
            examTitle: exam.title,
          ),
        ),
      );

      if (!mounted) return;

      _loadExams();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleReviewPressed(ExamModel exam) async {
    final examService = ref.read(
      examServiceProvider,
    ); // Get service from provider
    try {
      // 1. Lấy lượt thi mới nhất
      final attempt = await examService.getLatestAttempt(exam.id);
      if (!mounted) return;

      // 2. Lấy dữ liệu xem lại
      final reviewData = await examService.reviewExamAttempt(attempt.id);
      if (!mounted) return;

      // 3. Chuyển màn hình Review
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              QuizReviewScreen(examReview: reviewData, examId: exam.id),
        ),
      );

      // 4. Sau khi quay lại, kiểm tra mounted
      if (!mounted) return;

      // 5. Refresh danh sách
      _loadExams();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Boxicons.bx_arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Bộ trắc nghiệm",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: FutureBuilder<List<ExamModel>>(
        key: _futureBuilderKey,
        future: futureExams,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Lỗi: ${snapshot.error}",
                style: TextStyle(color: colorScheme.error),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "Không có bài kiểm tra",
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            );
          }

          final exams = snapshot.data!;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Text(
                      "Sau đây",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StudentExamHistoryScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Lịch sử",
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: exams.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return ExamCard(
                      exam: exams[index],
                      onPressed: () => _handleExamPressed(exams[index]),
                      onReviewPressed: () => _handleReviewPressed(exams[index]),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

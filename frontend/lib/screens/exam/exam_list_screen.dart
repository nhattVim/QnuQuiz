import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:frontend/models/exam_model.dart';
import 'package:frontend/screens/exam/widgets/exam_card.dart';
import 'package:frontend/screens/quiz/quiz_screen.dart';
import 'package:frontend/screens/quiz/quiz_review_screen.dart';
import 'package:frontend/screens/student_exam_history_screen.dart';
import 'package:frontend/services/exam_service.dart';

class ExamListScreen extends StatefulWidget {
  final int categoryId;

  const ExamListScreen({super.key, required this.categoryId});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  late Future<List<ExamModel>> futureExams;

  // Add a key to force rebuild FutureBuilder
  late Key _futureBuilderKey;

  @override
  void initState() {
    super.initState();
    _futureBuilderKey = UniqueKey();
    _loadExams();
  }

  void _loadExams() {
    futureExams = ExamService().getExamsByCategory(widget.categoryId);
    _futureBuilderKey = UniqueKey(); // Force rebuild
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Boxicons.bx_arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Bộ trắc nghiệm",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      body: FutureBuilder<List<ExamModel>>(
        key: _futureBuilderKey,
        future: futureExams,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Không có bài kiểm tra"));
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
                    const Text(
                      "Sau đây",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
                      child: const Text(
                        "Lịch sử",
                        style: TextStyle(
                          color: Colors.blue,
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
                      onPressed: () =>
                          _handleExamPressed(context, exams[index]),
                      onReviewPressed: () =>
                          _handleReviewPressed(context, exams[index]),
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

  Future<void> _handleExamPressed(BuildContext context, ExamModel exam) async {
    try {
      final attempt = await ExamService().startExam(exam.id);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizScreen(
            examId: exam.id,
            durationMinutes: exam.durationMinutes,
            examTitle: exam.title,
            attemptId: attempt.id,
          ),
        ),
      ).then((_) {
        // Refresh exam list khi quay lại từ quiz
        if (mounted) {
          setState(() {
            _loadExams();
          });
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleReviewPressed(
    BuildContext context,
    ExamModel exam,
  ) async {
    try {
      // Get the latest attempt WITHOUT creating a new one
      final attempt = await ExamService().getLatestAttempt(exam.id);

      if (!mounted) return;

      // Get review data
      final reviewData = await ExamService().reviewExamAttempt(attempt.id);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizReviewScreen(examReview: reviewData),
        ),
      ).then((_) {
        // Refresh exam list khi quay lại từ review
        if (mounted) {
          setState(() {
            _loadExams();
          });
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:frontend/models/exam_attempt_model.dart';
import 'package:frontend/models/exam_model.dart';
import 'package:frontend/screens/exam/widgets/exam_card.dart';
import 'package:frontend/screens/quiz/quiz_screen.dart';
import 'package:frontend/services/exam_service.dart';

class ExamListScreen extends StatefulWidget {
  final int categoryId;

  const ExamListScreen({super.key, required this.categoryId});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  late Future<List<ExamModel>> futureExams;

  @override
  void initState() {
    super.initState();
    futureExams = ExamService().getExamsByCategory(widget.categoryId);
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      "Sau đây",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Text(
                      "Lịch sử",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
                      onPressed: () async {
                        try {
                          ExamAttemptModel attempt = await ExamService()
                              .startExam(exams[index].id);

                          // Điều hướng sang QuizScreen, truyền examId và attemptId
                          if (!mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizScreen(
                                examId: exams[index].id,
                                durationMinutes: exams[index].durationMinutes,
                                attemptId: attempt.id,
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Không thể bắt đầu bài thi: $e"),
                            ),
                          );
                        }
                      },
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

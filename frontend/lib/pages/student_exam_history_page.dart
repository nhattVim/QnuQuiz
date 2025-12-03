import 'package:flutter/material.dart';
import 'package:frontend/models/exam_history_model.dart';
import 'package:frontend/services/exam_history_service.dart';

class StudentExamHistoryPage extends StatelessWidget {
  final ExamHistoryService service = ExamHistoryService();

  StudentExamHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lịch sử bài làm")),
      body: FutureBuilder<List<ExamHistoryModel>>(
        future: service.getExamHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Chưa có bài thi nào"));
          }

          final list = snapshot.data!;

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final item = list[i];

              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(item.examTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "Điểm: ${item.score}\n"
                    "Thời gian: ${item.durationMinutes} phút\n"
                    "Ngày hoàn thành: ${item.completionDate}",
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ExamHistoryDetailPage(history: item),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ExamHistoryDetailPage extends StatelessWidget {
  final ExamHistoryModel history;

  const ExamHistoryDetailPage({required this.history, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(history.examTitle)),
      body: ListView.builder(
        itemCount: history.answers.length,
        itemBuilder: (_, i) {
          final a = history.answers[i];
          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              title: Text(a.questionContent),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Bạn chọn: ${a.selectedOptionContent ?? a.answerText}"),
                  Text(
                    a.isCorrect ? "✔ Đúng" : "✘ Sai",
                    style: TextStyle(
                      color: a.isCorrect ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

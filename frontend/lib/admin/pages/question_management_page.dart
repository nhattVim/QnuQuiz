import 'package:flutter/material.dart';
import 'package:frontend/admin/widgets/question_form_dialog.dart';
import 'package:frontend/models/question_model.dart';
import 'package:frontend/services/question_service.dart';

class QuestionManagementPage extends StatefulWidget {
  const QuestionManagementPage({super.key});

  @override
  State<QuestionManagementPage> createState() => _QuestionManagementPageState();
}

class _QuestionManagementPageState extends State<QuestionManagementPage> {
  final QuestionService _questionService = QuestionService();
  late Future<List<QuestionModel>> _questionsFuture;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  void _fetchQuestions() {
    setState(() {
      _questionsFuture = _questionService.getAllQuestions();
    });
  }

  void _showQuestionFormDialog({QuestionModel? question}) {
    showDialog(
      context: context,
      builder: (context) => QuestionFormDialog(
        question: question,
        onSave: (newQuestion, examId) async {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          try {
            if (question == null) {
              if (examId != null) {
                await _questionService.createQuestion(newQuestion.toJson(), examId);
              } else {
                // Handle error: examId is required for new questions
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Exam ID is required for new questions.')),
                );
                return;
              }
            } else {
              await _questionService.updateQuestion(newQuestion);
            }
            if (!mounted) return;
            _fetchQuestions();
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('Question saved successfully!')),
            );
          } catch (e) {
            if (!mounted) return;
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text('Failed to save question: $e')),
            );
          }
        },
      ),
    );
  }

  void _confirmDeleteQuestion(int questionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              try {
                await _questionService.deleteQuestions([questionId]);
                if (!mounted) return;
                _fetchQuestions();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Question deleted successfully!')),
                );
                navigator.pop();
              } catch (e) {
                if (!mounted) return;
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Failed to delete question: $e')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Management'),
      ),
      body: FutureBuilder<List<QuestionModel>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No questions found.'));
          }

          final questions = snapshot.data!;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Content')),
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Exam ID')),
                DataColumn(label: Text('Actions')),
              ],
              rows: questions.map((question) {
                return DataRow(
                  cells: <DataCell>[
                    DataCell(Text(question.id.toString())),
                    DataCell(SizedBox(
                      width: 200,
                      child: Text(question.content ?? '', overflow: TextOverflow.ellipsis),
                    )),
                    DataCell(Text(question.type ?? '')),
                    DataCell(Text(question.examId?.toString() ?? '')),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showQuestionFormDialog(question: question),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _confirmDeleteQuestion(question.id!),
                        ),
                      ],
                    )),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuestionFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

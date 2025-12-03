import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/admin/widgets/exam_form_dialog.dart';
import 'package:frontend/models/exam_model.dart';
import 'package:frontend/providers/service_providers.dart';

class ExamManagementPage extends ConsumerStatefulWidget {
  const ExamManagementPage({super.key});

  @override
  ConsumerState<ExamManagementPage> createState() => _ExamManagementPageState();
}

class _ExamManagementPageState extends ConsumerState<ExamManagementPage> {
  late Future<List<ExamModel>> _examsFuture;

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  void _fetchExams() {
    final examService = ref.read(examServiceProvider);
    setState(() {
      _examsFuture = examService.getAllExams();
    });
  }

  void _showExamFormDialog({ExamModel? exam}) {
    showDialog(
      context: context,
      builder: (context) => ExamFormDialog(
        exam: exam,
        onSave: (newExam) async {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final examService = ref.read(examServiceProvider);
          try {
            if (exam == null) {
              await examService.createExam(newExam);
            } else {
              await examService.updateExam(newExam);
            }
            if (!mounted) return;
            _fetchExams();
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('Exam saved successfully!')),
            );
          } catch (e) {
            if (!mounted) return;
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text('Failed to save exam: $e')),
            );
          }
        },
      ),
    );
  }

  void _confirmDeleteExam(int examId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exam'),
        content: const Text('Are you sure you want to delete this exam?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final examService = ref.read(examServiceProvider);
              try {
                await examService.deleteExam(examId);
                if (!mounted) return;
                _fetchExams();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Exam deleted successfully!')),
                );
                navigator.pop();
              } catch (e) {
                if (!mounted) return;
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Failed to delete exam: $e')),
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
      appBar: AppBar(title: const Text('Exam Management')),
      body: FutureBuilder<List<ExamModel>>(
        future: _examsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No exams found.'));
          }

          final exams = snapshot.data!;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('Max Questions')),
                DataColumn(label: Text('Duration (min)')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Actions')),
              ],
              rows: exams.map((exam) {
                return DataRow(
                  cells: <DataCell>[
                    DataCell(Text(exam.id.toString())),
                    DataCell(Text(exam.title)),
                    DataCell(Text(exam.description)),
                    DataCell(Text(exam.maxQuestions?.toString() ?? '')),
                    DataCell(Text(exam.durationMinutes?.toString() ?? '')),
                    DataCell(Text(exam.categoryId.toString())),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showExamFormDialog(exam: exam),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _confirmDeleteExam(exam.id),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showExamFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

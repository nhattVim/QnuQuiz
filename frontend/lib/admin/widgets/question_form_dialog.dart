import 'package:flutter/material.dart';
import 'package:frontend/models/exam_model.dart';
import 'package:frontend/models/question_model.dart';
import 'package:frontend/models/question_option_model.dart';
import 'package:frontend/services/exam_service.dart';

class QuestionFormDialog extends StatefulWidget {
  final QuestionModel? question; // Null for create, not null for edit
  final Function(QuestionModel, int?) onSave; // Pass examId for new questions

  const QuestionFormDialog({super.key, this.question, required this.onSave});

  @override
  State<QuestionFormDialog> createState() => _QuestionFormDialogState();
}

class _QuestionFormDialogState extends State<QuestionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _contentController;
  late List<TextEditingController> _optionControllers;
  late List<bool> _isCorrectList;
  ExamModel? _selectedExam;
  late Future<List<ExamModel>> _examsFuture;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.question?.content ?? '');
    _optionControllers = [];
    _isCorrectList = [];
    _examsFuture = ExamService().getAllExams();

    if (widget.question != null && widget.question!.options != null) {
      for (var option in widget.question!.options!) {
        _optionControllers.add(TextEditingController(text: option.content));
        _isCorrectList.add(option.correct);
      }
    } else {
      // Add default options for new questions
      for (int i = 0; i < 4; i++) {
        _optionControllers.add(TextEditingController());
        _isCorrectList.add(false);
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
      _isCorrectList.add(false);
    });
  }

  void _removeOption(int index) {
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
      _isCorrectList.removeAt(index);
    });
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedExam == null && widget.question == null) {
        // Show error if exam not selected for new question
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an exam for the question.')),
        );
        return;
      }

      final List<QuestionOptionModel> options = _optionControllers.asMap().entries.map((entry) {
        final index = entry.key;
        final controller = entry.value;
        return QuestionOptionModel(
          id: widget.question?.options != null && index < widget.question!.options!.length
              ? widget.question!.options![index].id
              : 1,
          content: controller.text,
          correct: _isCorrectList[index],
          position: index + 1,
        );
      }).toList();

      final newQuestion = QuestionModel(
        id: widget.question?.id, // Null for new, existing for update
        content: _contentController.text,
        type: 'MULTIPLE_CHOICE', // Assuming multiple choice for now
        options: options,
      );
      widget.onSave(
        newQuestion,
        _selectedExam?.id,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.question == null ? 'Create New Question' : 'Edit Question'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Question Content'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter question content';
                  }
                  return null;
                },
              ),
              if (widget.question == null) // Only show exam selection for new questions
                FutureBuilder<List<ExamModel>>(
                  future: _examsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error loading exams: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No exams available');
                    }
                    _selectedExam ??= snapshot.data!.first; // Default to first exam
                    return DropdownButtonFormField<ExamModel>(
                      decoration: const InputDecoration(labelText: 'Select Exam'),
                      initialValue: _selectedExam,
                      items: snapshot.data!
                          .map((exam) => DropdownMenuItem(
                                value: exam,
                                child: Text(exam.title),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedExam = value;
                        });
                      },
                    );
                  },
                ),
              const SizedBox(height: 16),
              const Text('Options:', style: TextStyle(fontWeight: FontWeight.bold)),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _optionControllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _optionControllers[index],
                          decoration: InputDecoration(labelText: 'Option ${index + 1}'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter option content';
                            }
                            return null;
                          },
                        ),
                      ),
                      Checkbox(
                        value: _isCorrectList[index],
                        onChanged: (value) {
                          setState(() {
                            _isCorrectList[index] = value!;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () => _removeOption(index),
                      ),
                    ],
                  );
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _addOption,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Option'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveForm,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

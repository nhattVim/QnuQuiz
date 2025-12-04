import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exam_model.dart';
import 'package:frontend/models/question_model.dart';
import 'package:frontend/models/question_option_model.dart';
import 'package:frontend/providers/service_providers.dart';

class QuestionFormDialog extends ConsumerStatefulWidget {
  final QuestionModel? question;
  final Function(QuestionModel, int?) onSave;

  const QuestionFormDialog({super.key, this.question, required this.onSave});

  @override
  ConsumerState<QuestionFormDialog> createState() => _QuestionFormDialogState();
}

class _QuestionFormDialogState extends ConsumerState<QuestionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _contentController;
  late List<TextEditingController> _optionControllers;
  late List<bool> _isCorrectList;
  ExamModel? _selectedExam;
  late Future<List<ExamModel>> _examsFuture;

  bool get _isEditing => widget.question != null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _isEditing ? 'Edit Question' : 'Create New Question',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Question Content',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter question content';
                  }
                  return null;
                },
              ),
              if (!_isEditing)
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
                    _selectedExam ??= snapshot.data!.first;
                    return DropdownButtonFormField<ExamModel>(
                      decoration: const InputDecoration(
                        labelText: 'Select Exam',
                      ),
                      initialValue: _selectedExam,
                      items: snapshot.data!
                          .map(
                            (exam) => DropdownMenuItem(
                              value: exam,
                              child: Text(exam.title),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() {
                        _selectedExam = value;
                      }),
                    );
                  },
                ),
              const SizedBox(height: 16),
              const Text(
                'Options:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _optionControllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _optionControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Option ${index + 1}',
                          ),
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
                        tooltip: 'Remove option',
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
        ElevatedButton(onPressed: _saveForm, child: const Text('Save')),
      ],
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: widget.question?.content ?? '',
    );
    _optionControllers = [];
    _isCorrectList = [];
    _examsFuture = ref.read(examServiceProvider).getAllExams();

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

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
      _isCorrectList.add(false);
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A question must have at least 2 options.')),
      );
      return;
    }
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
      _isCorrectList.removeAt(index);
    });
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      if (!_isEditing && _selectedExam == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an exam for the question.'),
          ),
        );
        return;
      }

      if (!_isCorrectList.contains(true)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please mark at least one correct option.')),
        );
        return;
      }

      final List<QuestionOptionModel> options = _optionControllers
          .asMap()
          .entries
          .map((entry) {
            final index = entry.key;
            final controller = entry.value;
            return QuestionOptionModel(
              id: widget.question?.options != null &&
                      index < widget.question!.options!.length
                  ? widget.question!.options![index].id
                  : null,
              content: controller.text,
              correct: _isCorrectList[index],
              position: index + 1,
            );
          })
          .toList();

      final newQuestion = QuestionModel(
        id: widget.question?.id,
        content: _contentController.text,
        type: widget.question?.type ?? 'MULTIPLE_CHOICE',
        options: options,
      );
      widget.onSave(newQuestion, _selectedExam?.id ?? widget.question?.examId);
      Navigator.of(context).pop();
    }
  }
}

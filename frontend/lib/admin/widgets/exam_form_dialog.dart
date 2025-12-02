import 'package:flutter/material.dart';
import 'package:frontend/models/exam_category_model.dart';
import 'package:frontend/models/exam_model.dart';
import 'package:frontend/services/exam_service.dart';

class ExamFormDialog extends StatefulWidget {
  final ExamModel? exam; // Null for create, not null for edit
  final Function(ExamModel) onSave;

  const ExamFormDialog({super.key, this.exam, required this.onSave});

  @override
  State<ExamFormDialog> createState() => _ExamFormDialogState();
}

class _ExamFormDialogState extends State<ExamFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _maxQuestionsController;
  late TextEditingController _durationMinutesController;
  late TextEditingController _passScoreController;
  ExamCategoryModel? _selectedCategory;
  late Future<List<ExamCategoryModel>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.exam?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.exam?.description ?? '',
    );
    _maxQuestionsController = TextEditingController(
      text: widget.exam?.maxQuestions?.toString() ?? '',
    );
    _durationMinutesController = TextEditingController(
      text: widget.exam?.durationMinutes?.toString() ?? '',
    );
    _categoriesFuture = ExamService().getAllCategories();

    if (widget.exam != null) {
      _categoriesFuture.then((categories) {
        setState(() {
          _selectedCategory = categories.firstWhere(
            (cat) => cat.id == widget.exam!.categoryId,
            orElse: () => categories.first,
          );
        });
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _maxQuestionsController.dispose();
    _durationMinutesController.dispose();
    _passScoreController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newExam = ExamModel(
        id: widget.exam!.id, // Null for new, existing for update
        title: _titleController.text,
        description: _descriptionController.text,
        maxQuestions: int.tryParse(_maxQuestionsController.text),
        durationMinutes: int.tryParse(_durationMinutesController.text),
        categoryId: _selectedCategory!.id,
        random: widget.exam?.random ?? false,
        status: widget.exam!.status,
      );
      widget.onSave(newExam);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.exam == null ? 'Create New Exam' : 'Edit Exam'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _maxQuestionsController,
                decoration: const InputDecoration(labelText: 'Max Questions'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _durationMinutesController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter duration';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid number of minutes';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passScoreController,
                decoration: const InputDecoration(labelText: 'Pass Score'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pass score';
                  }
                  if (int.tryParse(value) == null ||
                      int.parse(value) < 0 ||
                      int.parse(value) > 100) {
                    return 'Please enter a valid score (0-100)';
                  }
                  return null;
                },
              ),
              FutureBuilder<List<ExamCategoryModel>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error loading categories: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No categories available');
                  }

                  return DropdownButtonFormField<ExamCategoryModel>(
                    decoration: const InputDecoration(labelText: 'Category'),
                    initialValue: _selectedCategory ?? snapshot.data!.first,
                    items: snapshot.data!
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  );
                },
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
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exam_category_model.dart';
import 'package:frontend/models/exam_model.dart';
import 'package:frontend/providers/service_providers.dart';
import 'package:intl/intl.dart';

class ExamFormDialog extends ConsumerStatefulWidget {
  final ExamModel? exam; // Null for create, not null for edit
  final Function(ExamModel) onSave;

  const ExamFormDialog({super.key, this.exam, required this.onSave});

  @override
  ConsumerState<ExamFormDialog> createState() => _ExamFormDialogState();
}

class _ExamFormDialogState extends ConsumerState<ExamFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _maxQuestionsController;
  late TextEditingController _durationMinutesController;
  ExamCategoryModel? _selectedCategory;
  late Future<List<ExamCategoryModel>> _categoriesFuture;
  late bool _randomizeQuestions;
  late String _status;
  late List<String> _statusOptions;
  DateTime? _startTime;
  DateTime? _endTime;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

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
    _randomizeQuestions = widget.exam?.random ?? false;
    final defaultStatuses = ['DRAFT', 'PUBLISHED', 'CLOSED'];
    _status = widget.exam?.status ?? defaultStatuses.first;
    _statusOptions = {
      ...defaultStatuses,
      if (widget.exam?.status != null) widget.exam!.status,
    }.toList();
    _startTime = widget.exam?.startTime;
    _endTime = widget.exam?.endTime;
    _categoriesFuture = ref.read(examServiceProvider).getAllCategories();

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
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category.')),
        );
        return;
      }
      final newExam = ExamModel(
        id: widget.exam?.id ?? 0,
        title: _titleController.text,
        description: _descriptionController.text,
        maxQuestions: int.tryParse(_maxQuestionsController.text),
        durationMinutes: int.tryParse(_durationMinutesController.text),
        categoryId: _selectedCategory!.id,
        random: _randomizeQuestions,
        status: _status,
        startTime: _startTime,
        endTime: _endTime,
        hasUnfinishedAttempt: widget.exam?.hasUnfinishedAttempt ?? false,
        hasAttempt: widget.exam?.hasAttempt ?? false,
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

                  _selectedCategory ??= snapshot.data!.first;

                  return Column(
                    children: [
                      DropdownButtonFormField<ExamCategoryModel>(
                        key: ValueKey(_selectedCategory?.id),
                        decoration: const InputDecoration(labelText: 'Category'),
                        initialValue: _selectedCategory,
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
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        key: ValueKey(_status),
                        decoration: const InputDecoration(labelText: 'Status'),
                        initialValue: _status,
                        items: _statusOptions
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _status = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Randomize questions'),
                        value: _randomizeQuestions,
                        onChanged: (value) =>
                            setState(() => _randomizeQuestions = value),
                      ),
                      const SizedBox(height: 12),
                      _DateTimePickerTile(
                        label: 'Start time',
                        value: _startTime,
                        formatter: _dateFormat,
                        onPressed: () => _pickDateTime(isStart: true),
                      ),
                      const SizedBox(height: 8),
                      _DateTimePickerTile(
                        label: 'End time',
                        value: _endTime,
                        formatter: _dateFormat,
                        onPressed: () => _pickDateTime(isStart: false),
                      ),
                    ],
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

  Future<void> _pickDateTime({required bool isStart}) async {
    final initialDate = (isStart ? _startTime : _endTime) ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null || !mounted) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        _startTime = selected;
      } else {
        _endTime = selected;
      }
    });
  }
}

class _DateTimePickerTile extends StatelessWidget {
  const _DateTimePickerTile({
    required this.label,
    required this.value,
    required this.formatter,
    required this.onPressed,
  });

  final String label;
  final DateTime? value;
  final DateFormat formatter;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(
        value == null ? 'Not set' : formatter.format(value!),
      ),
      trailing: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.schedule),
        label: const Text('Pick'),
      ),
    );
  }
}

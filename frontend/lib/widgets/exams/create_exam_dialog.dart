import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/models/exam_category_model.dart';
import 'package:frontend/models/exam_model.dart';
import 'package:frontend/services/exam_service.dart';
import 'package:intl/intl.dart';

class CreateExamDialog extends StatefulWidget {
  const CreateExamDialog({super.key});

  @override
  State<CreateExamDialog> createState() => _CreateExamDialogState();
}

class _CreateExamDialogState extends State<CreateExamDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _durationController = TextEditingController();
  final _examService = ExamService();

  String _status = 'DRAFT';
  int _category = 1;
  bool _random = false;
  DateTime? _startTime;
  DateTime? _endTime;
  bool _isLoading = false;

  final List<String> _statusOptions = ['DRAFT', 'PUBLISHED'];
  List<ExamCategoryModel> _categoryOptions = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      filled: true,
      fillColor: theme.colorScheme.surface,
    );

    return AlertDialog(
      title: const Text('Tạo bộ câu hỏi mới'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: inputDecoration.copyWith(labelText: 'Tiêu đề'),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) => v?.isEmpty == true ? 'Nhập tiêu đề' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _descController,
                  decoration: inputDecoration.copyWith(labelText: 'Mô tả'),
                  maxLines: 2,
                  validator: (v) => v?.isEmpty == true ? 'Nhập mô tả' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: inputDecoration.copyWith(
                    labelText: 'Thời gian (phút)',
                  ),
                  validator: (v) =>
                      v?.isEmpty == true ? 'Nhập thời gian' : null,
                ),
                SizedBox(height: 16.h),
                _buildDateTimePicker(
                  label: "Bắt đầu",
                  value: _startTime,
                  onPressed: () => _pickDateTime(true),
                ),
                SizedBox(height: 16.h),
                _buildDateTimePicker(
                  label: "Kết thúc",
                  value: _endTime,
                  onPressed: () => _pickDateTime(false),
                ),
                SizedBox(height: 16.h),

                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: inputDecoration.copyWith(labelText: 'Trạng thái'),
                  items: _statusOptions
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _status = v!),
                  dropdownColor: theme.colorScheme.surfaceContainer,
                ),

                SizedBox(height: 16.h),
                DropdownButtonFormField<int>(
                  initialValue: _category,
                  decoration: inputDecoration.copyWith(labelText: 'Danh mục'),
                  items: _categoryOptions
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.id,
                          child: Text(
                            e.name,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                  dropdownColor: theme.colorScheme.surfaceContainer,
                ),

                SizedBox(height: 8.h),
                Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                  child: SwitchListTile(
                    title: const Text("Trộn câu hỏi"),
                    value: _random,
                    onChanged: (v) => setState(() => _random = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Tạo'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Widget _buildDateTimePicker({
    required String label,
    required DateTime? value,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.r),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              _formatDateTime(value),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: value == null
                    ? theme.hintColor
                    : theme.colorScheme.onSurface,
              ),
            ),
            Icon(
              Icons.calendar_today,
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime? dt) =>
      dt == null ? "Chưa chọn" : DateFormat('dd/MM/yyyy HH:mm').format(dt);

  void _loadCategories() async {
    final data = await _examService.getAllCategories();
    setState(() {
      _categoryOptions = data;
    });
  }

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn thời gian'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final newExam = ExamModel(
        id: 0,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        startTime: _startTime!,
        endTime: _endTime!,
        durationMinutes: int.parse(_durationController.text),
        status: _status,
        random: _random,
        categoryId: _category,
      );
      await _examService.createExam(newExam);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

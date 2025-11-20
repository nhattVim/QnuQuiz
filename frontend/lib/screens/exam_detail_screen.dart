import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/models/exam_model.dart';
import 'package:frontend/models/question_model.dart';
import 'package:frontend/screens/question_edit_screen.dart';
import 'package:frontend/services/exam_service.dart';
import 'package:frontend/services/question_service.dart';
import 'package:intl/intl.dart';

class ExamDetailScreen extends StatefulWidget {
  final ExamModel exam;
  const ExamDetailScreen({super.key, required this.exam});

  @override
  State<ExamDetailScreen> createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends State<ExamDetailScreen> {
  // Services
  final _examService = ExamService();
  final _questionService = QuestionService();

  // Model
  ExamModel? _updatedExam;
  late Future<List<QuestionModel>> _questionsFuture;
  List<QuestionModel> _questionsList = [];

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _durationController;

  // State
  late String _status;
  DateTime? _startTime;
  DateTime? _endTime;
  final List<String> _statusOptions = ['DRAFT', 'PUBLISHED'];

  // State for deleting questions
  bool _isDeleting = false;
  final Set<int> _selectedQuestions = {};

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.exam.title);
    _descriptionController = TextEditingController(
      text: widget.exam.description,
    );
    _durationController = TextEditingController(
      text: widget.exam.durationMinutes?.toString() ?? '',
    );
    _status = widget.exam.status;
    _startTime = widget.exam.startTime;
    _endTime = widget.exam.endTime;
    _questionsFuture = _questionService.getQuestions(widget.exam.id);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context, _updatedExam);
      },
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: TextField(
                  controller: _titleController,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Nhập tiêu đề...',
                    hintStyle: TextStyle(color: theme.hintColor),
                    border: InputBorder.none,
                  ),
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: OutlinedButton.icon(
                      onPressed: _save,
                      icon: Icon(Icons.save_alt_outlined, size: 16.sp),
                      label: const Text("Lưu"),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ),
                ],
                pinned: true,
                floating: true,
                forceElevated: innerBoxIsScrolled,
              ),
            ];
          },
          body: Column(
            children: [
              _buildExamDetailsForm(),
              _buildQuestionListHeader(),
              Expanded(child: _buildQuestionList()),
            ],
          ),
        ),
        floatingActionButton: !_isDeleting
            ? FloatingActionButton(
                onPressed: () {
                  // TODO: Navigate to create question screen
                },
                tooltip: 'Tạo câu hỏi mới',
                child: const Icon(Icons.add),
              )
            : null,
        bottomNavigationBar: _isDeleting ? _buildDeleteAppBar() : null,
      ),
    );
  }

  Widget _buildExamDetailsForm() {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          TextField(
            controller: _descriptionController,
            decoration: _inputDecoration(
              'Mô tả',
              prefixIcon: const Icon(Icons.description_outlined),
            ),
            maxLines: 3,
            minLines: 1,
          ),
          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    'Thời gian (phút)',
                    prefixIcon: const Icon(Icons.timer_outlined),
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // 3. Dropdown Trạng thái
              Expanded(
                child: InkWell(
                  onTap: _pickStatus,
                  borderRadius: BorderRadius.circular(12.r),
                  child: InputDecorator(
                    decoration: _inputDecoration(
                      'Trạng thái',
                      prefixIcon: const Icon(Icons.label_outline),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _status,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _pickDateTime(isStart: true),
                  borderRadius: BorderRadius.circular(12.r),
                  child: InputDecorator(
                    decoration: _inputDecoration(
                      'Bắt đầu',
                      prefixIcon: const Icon(Icons.event_outlined),
                    ),
                    child: Text(
                      _startTime != null
                          ? formatter.format(_startTime!)
                          : 'Chưa chọn',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: InkWell(
                  onTap: () => _pickDateTime(isStart: false),
                  borderRadius: BorderRadius.circular(12.r),
                  child: InputDecorator(
                    decoration: _inputDecoration(
                      'Kết thúc',
                      prefixIcon: const Icon(Icons.event_available_outlined),
                    ),
                    child: Text(
                      _endTime != null
                          ? formatter.format(_endTime!)
                          : 'Chưa chọn',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionListHeader() {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Danh sách câu hỏi',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!_isDeleting)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.file_upload_outlined),
                  tooltip: 'Import từ Excel',
                  onPressed: _import,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Chọn để xóa',
                  onPressed: _toggleDeleteMode,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionList() {
    return FutureBuilder<List<QuestionModel>>(
      future: _questionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Lỗi: ${snapshot.error}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          _questionsList = [];
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: 48.sp,
                  color: Theme.of(context).disabledColor,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Chưa có câu hỏi nào.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        _questionsList = snapshot.data!;
        return ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          itemCount: _questionsList.length,
          separatorBuilder: (_, _) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final question = _questionsList[index];
            final isSelected = _selectedQuestions.contains(question.id);
            return _questionCard(
              question: question,
              index: index + 1,
              isSelected: isSelected,
              onSelected: () => _onSelectQuestion(question.id),
            );
          },
        );
      },
    );
  }

  Widget _questionCard({
    required QuestionModel question,
    required int index,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    final theme = Theme.of(context);

    final cardColor = isSelected
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
        : null;
    final borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.dividerColor.withValues(alpha: 0.5);

    return Card(
      elevation: isSelected ? 0 : 1,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: borderColor, width: 1.2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () async {
          if (_isDeleting) {
            onSelected();
          } else {
            final updatedQuestion = await Navigator.push<QuestionModel?>(
              context,
              MaterialPageRoute(
                builder: (context) => QuestionEditScreen(question: question),
              ),
            );

            if (updatedQuestion != null) {
              setState(() {
                final questionIndex = _questionsList.indexWhere(
                  (q) => q.id == updatedQuestion.id,
                );
                if (questionIndex != -1) {
                  _questionsList[questionIndex] = updatedQuestion;
                }
              });
            }
          }
        },
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          leading: _isDeleting
              ? Checkbox(
                  value: isSelected,
                  onChanged: (bool? value) => onSelected(),
                )
              : CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  child: Text(
                    '$index',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
          title: Text(
            question.content,
            style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: !_isDeleting
              ? Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: theme.colorScheme.onSurfaceVariant,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildDeleteAppBar() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Checkbox(
                value:
                    _questionsList.isNotEmpty &&
                    _selectedQuestions.length == _questionsList.length,
                tristate:
                    _questionsList.isNotEmpty &&
                    _selectedQuestions.isNotEmpty &&
                    _selectedQuestions.length < _questionsList.length,
                onChanged: _toggleSelectAll,
              ),
              Text(
                'Đã chọn ${_selectedQuestions.length}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: _toggleDeleteMode,
                child: const Text('Hủy'),
              ),
              SizedBox(width: 8.w),
              FilledButton.icon(
                onPressed: _selectedQuestions.isEmpty
                    ? null
                    : _deleteSelectedQuestions,
                icon: const Icon(Icons.delete_forever_outlined),
                label: const Text('Xóa'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {Widget? prefixIcon}) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      filled: true,
      fillColor: theme.colorScheme.surface,
    );
  }

  void _import() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );
      if (!mounted) return;
      if (result == null || result.files.single.path == null) return;

      File file = File(result.files.single.path!);
      await _questionService.importQuestions(file, widget.exam.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Import thành công'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _questionsFuture = _questionService.getQuestions(widget.exam.id);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final initial = isStart
        ? (_startTime ?? DateTime.now())
        : (_endTime ?? DateTime.now().add(const Duration(hours: 1)));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (!mounted || date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (!mounted || time == null) return;

    setState(() {
      final dt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (isStart) {
        _startTime = dt;
      } else {
        _endTime = dt;
      }
    });
  }

  Future<void> _pickStatus() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _statusOptions
              .map(
                (s) => ListTile(
                  title: Text(s),
                  trailing: _status == s
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () => Navigator.pop(context, s),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (selected != null) setState(() => _status = selected);
  }

  void _save() async {
    final updated = ExamModel(
      id: widget.exam.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startTime: _startTime,
      endTime: _endTime,
      random: widget.exam.random,
      durationMinutes: int.tryParse(_durationController.text),
      status: _status,
    );

    try {
      final result = await _examService.updateExam(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thành công'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() => _updatedExam = result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _toggleDeleteMode() {
    setState(() {
      _isDeleting = !_isDeleting;
      _selectedQuestions.clear();
    });
  }

  void _onSelectQuestion(int questionId) {
    setState(() {
      if (_selectedQuestions.contains(questionId)) {
        _selectedQuestions.remove(questionId);
      } else {
        _selectedQuestions.add(questionId);
      }
    });
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectedQuestions.addAll(_questionsList.map((q) => q.id));
      } else {
        _selectedQuestions.clear();
      }
    });
  }

  void _deleteSelectedQuestions() async {
    if (_selectedQuestions.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa ${_selectedQuestions.length} câu hỏi đã chọn?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Xóa',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _questionService.deleteQuestions(List.from(_selectedQuestions));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa câu hỏi thành công'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _questionsFuture = _questionService.getQuestions(widget.exam.id);
        _isDeleting = false;
        _selectedQuestions.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

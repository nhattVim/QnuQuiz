import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/models/exam_model.dart';
import 'package:frontend/models/question_model.dart';
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
  List<QuestionModel> _questionsDelList = [];

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
  Set<int> _selectedQuestions = {};

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context, _updatedExam);
      },
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _titleController,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              hintText: 'Nhập tiêu đề...',
              hintStyle: TextStyle(color: Colors.black54),
              border: InputBorder.none,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: TextButton(
                onPressed: _save,
                child: Text("Save", style: TextStyle(fontSize: 16.sp)),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Description
              TextField(
                controller: _descriptionController,
                decoration: _inputDecoration('Mô tả', icon: Icons.description),
                maxLines: 3,
              ),

              SizedBox(height: 16.h),

              // Duration + Status
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        'Thời gian (phút)',
                        icon: Icons.timer,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: InkWell(
                      onTap: _pickStatus,
                      borderRadius: BorderRadius.circular(12.r),
                      child: InputDecorator(
                        decoration: _inputDecoration(
                          'Trạng thái',
                          icon: Icons.label,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _status,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14.sp,
                              ),
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

              // Start + End time
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDateTime(isStart: true),
                      borderRadius: BorderRadius.circular(12.r),
                      child: InputDecorator(
                        decoration: _inputDecoration(
                          'Bắt đầu',
                          icon: Icons.event,
                        ),
                        child: Text(
                          _startTime != null
                              ? formatter.format(_startTime!)
                              : 'Chưa chọn',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15.sp,
                          ),
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
                          icon: Icons.event_available,
                        ),
                        child: Text(
                          _endTime != null
                              ? formatter.format(_endTime!)
                              : 'Chưa chọn',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Question list title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Danh sách câu hỏi',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_isDeleting) ...[
                    // Delete mode
                    Text(
                      'Đã chọn: ${_selectedQuestions.length}',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    Checkbox(
                      value:
                          _questionsDelList.isNotEmpty &&
                          _selectedQuestions.length == _questionsDelList.length,
                      tristate:
                          _questionsDelList.isNotEmpty &&
                          _selectedQuestions.isNotEmpty &&
                          _selectedQuestions.length < _questionsDelList.length,
                      onChanged: _toggleSelectAll,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_forever_outlined,
                        color: Colors.red,
                      ),
                      tooltip: 'Xóa câu hỏi đã chọn',
                      onPressed: _selectedQuestions.isEmpty
                          ? null
                          : _deleteSelectedQuestions,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Hủy',
                      onPressed: _toggleDeleteMode,
                    ),
                  ] else ...[
                    // Normal mode
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
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          tooltip: 'Tạo câu hỏi mới',
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ],
              ),

              SizedBox(height: 8.h),

              // Question List
              Expanded(
                child: FutureBuilder<List<QuestionModel>>(
                  future: _questionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Lỗi: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      _questionsDelList = [];
                      return const Center(
                        child: Text(
                          'Chưa có câu hỏi nào.\nHãy thêm mới hoặc import từ file.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    final questions = snapshot.data!;
                    _questionsDelList = questions;

                    return ListView.separated(
                      itemCount: questions.length,
                      separatorBuilder: (_, _) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        final isSelected = _selectedQuestions.contains(
                          question.id,
                        );

                        return questionCard(
                          question: question,
                          index: index + 1,
                          isDeleting: _isDeleting,
                          isSelected: isSelected,
                          onSelected: () => _onSelectQuestion(question.id),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

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
    _status = widget.exam.status == 'DRAFT' ? 'DRAFT' : 'PUBLISHED';
    _startTime = widget.exam.startTime;
    _endTime = widget.exam.endTime;
    _questionsFuture = _questionService.getQuestions(widget.exam.id);

    _isDeleting = false;
    _selectedQuestions = {};
    _questionsDelList = [];
  }

  Widget questionCard({
    required QuestionModel question,
    required int index,
    required bool isDeleting,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          // Nếu đang xóa, thì nhấn là để chọn/bỏ chọn
          // Ngược lại thì sang trang edit
          if (isDeleting) {
            onSelected();
          } else {
            // TODO: Navigate to edit question
            print("question content: ${question.content}");
            for (var i = 0; i < question.options.length; i++) {
              print(question.options[i].content);
              print("");
            }
          }
        },
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isDeleting)
                Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) => onSelected(),
                  ),
                ),
              Expanded(
                child: Text(
                  question.content,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              SizedBox(width: 8.w),
              if (!isDeleting) Icon(Icons.arrow_forward_ios, size: 16.sp),
            ],
          ),
        ),
      ),
    );
  }

  // import question from excel file
  void _import() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (!mounted) return;

      if (result == null || result.files.single.path == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Chưa chọn file')));
        return;
      }

      File file = File(result.files.single.path!);
      await _questionService.importQuestions(file, widget.exam.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Import thành công 🎉'),
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

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, size: 20.sp) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  // Pick DateTime
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

  // Pick Status
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
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () => Navigator.pop(context, s),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (selected != null) {
      setState(() => _status = selected);
    }
  }

  // Save
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
        _selectedQuestions = _questionsDelList.map((q) => q.id).toSet();
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
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
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
        _questionsDelList = [];
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

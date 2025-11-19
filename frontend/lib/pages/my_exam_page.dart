import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/models/exam_model.dart';
import 'package:frontend/screens/exam_detail_screen.dart';
import 'package:frontend/services/exam_service.dart';
import 'package:intl/intl.dart';

extension ExamModelExtension on ExamModel {
  Color get _baseColor {
    switch (status) {
      case "ACTIVE":
        return Colors.green;
      case "CLOSED":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color get statusColor => _baseColor;

  String get statusText {
    switch (status) {
      case "ACTIVE":
        return "Đang mở";
      case "CLOSED":
        return "Đã đóng";
      default:
        return "Bản nháp";
    }
  }

  String get dateRangeText {
    if (startTime != null && endTime != null) {
      final dfDay = DateFormat('dd');
      final dfFull = DateFormat('dd/MM/yyyy');
      return '${dfDay.format(startTime!)} - ${dfFull.format(endTime!)}';
    }
    return "N/A";
  }
}

class MyExamPage extends StatefulWidget {
  const MyExamPage({super.key});

  @override
  State<MyExamPage> createState() => _MyExamPageState();
}

class _MyExamPageState extends State<MyExamPage> {
  final _examService = ExamService();
  bool _sortDesc = true;
  late Future<List<ExamModel>> _examsFuture;

  @override
  void initState() {
    super.initState();
    _refreshExams();
  }

  void _refreshExams() {
    setState(() {
      _examsFuture = _examService.getExamsByUserId(_sortDesc);
    });
  }

  void _toggleSort() {
    setState(() {
      _sortDesc = !_sortDesc;
    });
    _refreshExams();
  }

  Future<void> _openCreateDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const CreateExamDialog(),
    );

    if (result == true) {
      _refreshExams();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              _buildHeader(),

              SizedBox(height: 12.h),

              Expanded(
                child: FutureBuilder<List<ExamModel>>(
                  future: _examsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Lỗi: ${snapshot.error}',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.quiz_outlined,
                              size: 64.sp,
                              color: theme.disabledColor,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Không có bộ câu hỏi nào',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final exams = snapshot.data!;

                    return RefreshIndicator(
                      onRefresh: () async => _refreshExams(),
                      child: ListView.separated(
                        padding: EdgeInsets.only(bottom: 100.h),
                        itemCount: exams.length,
                        separatorBuilder: (_, _) => SizedBox(height: 16.h),
                        itemBuilder: (context, index) {
                          return ExamCard(
                            exam: exams[index],
                            onDelete: () => _confirmDelete(exams[index]),
                            onUpdate: (updatedExam) {
                              setState(() {
                                exams[index] = updatedExam;
                              });
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Tạo mới'),
      ),
    );
  }

  void _confirmDelete(ExamModel exam) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text.rich(
          TextSpan(
            text: 'Bạn có chắc muốn xóa bộ câu hỏi ',
            children: [
              TextSpan(
                text: '"${exam.title}"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' không?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text(
              'Xóa',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onPressed: () {
              _examService.deleteExam(exam.id);
              _refreshExams();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Bộ câu hỏi của tôi",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          OutlinedButton.icon(
            onPressed: _toggleSort,
            icon: Icon(
              _sortDesc ? Icons.arrow_downward : Icons.arrow_upward,
              size: 16.sp,
            ),
            label: Text(_sortDesc ? "Mới nhất" : "Cũ nhất"),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
              side: BorderSide(color: theme.dividerColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExamCard extends StatelessWidget {
  final ExamModel exam;
  final Function(ExamModel) onUpdate;
  final VoidCallback onDelete;

  const ExamCard({
    super.key,
    required this.exam,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () async {
          final updatedExam = await Navigator.push<ExamModel>(
            context,
            MaterialPageRoute(builder: (_) => ExamDetailScreen(exam: exam)),
          );
          if (updatedExam != null) onUpdate(updatedExam);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Avatar
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.school_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      exam.dateRangeText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        _buildStatusChip(context, isDark),
                        SizedBox(width: 12.w),
                        _buildIconText(
                          Icons.timer_outlined,
                          '${exam.durationMinutes ?? 0} phút',
                          theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Menu Option
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.more_vert,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onSelected: (value) {
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: theme.colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Xóa',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, bool isDark) {
    Color color;
    final baseColor = exam.statusColor;

    if (baseColor == Colors.green) {
      color = isDark ? Colors.greenAccent.shade200 : Colors.green.shade700;
    } else if (baseColor == Colors.red) {
      color = isDark ? Colors.redAccent.shade200 : Colors.red.shade700;
    } else {
      color = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        exam.statusText,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text, TextStyle? style) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: style?.color?.withValues(alpha: 0.7)),
        SizedBox(width: 4.w),
        Text(text, style: style),
      ],
    );
  }
}

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
  bool _random = false;
  DateTime? _startTime;
  DateTime? _endTime;
  bool _isLoading = false;

  final List<String> _statusOptions = ['DRAFT', 'PUBLISHED'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _durationController.dispose();
    super.dispose();
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

  String _formatDateTime(DateTime? dt) =>
      dt == null ? "Chưa chọn" : DateFormat('dd/MM/yyyy HH:mm').format(dt);

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
                  dropdownColor: theme.colorScheme.surfaceContainer, // Nền menu
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
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/providers/service_providers.dart';

class QuestionCreateScreen extends ConsumerStatefulWidget {
  final int examId;
  const QuestionCreateScreen({super.key, required this.examId});

  @override
  ConsumerState<QuestionCreateScreen> createState() =>
      _QuestionCreateScreenState();
}

class _QuestionCreateScreenState extends ConsumerState<QuestionCreateScreen> {
  // Controllers
  final _contentController = TextEditingController();
  final List<TextEditingController> _optionControllers = [];

  // State
  int _correctOptionIndex = -1;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo câu hỏi mới'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            child: const Text('Hủy bỏ'),
          ),
          SizedBox(width: 8.w),
          OutlinedButton.icon(
            onPressed: _isSaving ? null : _saveQuestion,
            icon: _isSaving
                ? SizedBox(
                    width: 16.sp,
                    height: 16.sp,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.save_alt_outlined, size: 16.sp),
            label: const Text("Lưu"),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          SizedBox(width: 12.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nội dung câu hỏi',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _contentController,
              minLines: 3,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: 'Nhập nội dung câu hỏi...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Các đáp án',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addOption,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm đáp án'),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _optionControllers.length,
              itemBuilder: (context, index) {
                return _buildOptionEditor(
                  index: index,
                  controller: _optionControllers[index],
                );
              },
            ),
          ],
        ),
      ),
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
    // Start with 4 empty options
    for (int i = 0; i < 4; i++) {
      _addOption();
    }
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  Widget _buildOptionEditor({
    required int index,
    required TextEditingController controller,
  }) {
    final theme = Theme.of(context);
    final isCorrect = index == _correctOptionIndex;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      elevation: isCorrect ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
        side: BorderSide(
          color: isCorrect ? theme.colorScheme.primary : theme.dividerColor,
          width: isCorrect ? 2.0 : 0.5,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đáp án ${String.fromCharCode(65 + index)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _selectCorrectOption(index),
                      icon: isCorrect
                          ? Icon(
                              Icons.check_circle,
                              color: theme.colorScheme.primary,
                            )
                          : Icon(
                              Icons.circle_outlined,
                              color: theme.colorScheme.outline,
                            ),
                      label: Text(isCorrect ? 'Đúng' : 'Đặt làm đúng'),
                      style: TextButton.styleFrom(
                        foregroundColor: isCorrect
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    if (_optionControllers.length > 2)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: theme.colorScheme.error,
                        ),
                        onPressed: () => _removeOption(index),
                        tooltip: 'Xóa đáp án',
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: controller,
              minLines: 1,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Nhập nội dung đáp án',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeOption(int index) {
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
      if (_correctOptionIndex == index) {
        _correctOptionIndex = -1;
      } else if (_correctOptionIndex > index) {
        _correctOptionIndex--;
      }
    });
  }

  void _saveQuestion() async {
    if (_contentController.text.trim().isEmpty) {
      _showError('Nội dung câu hỏi không được để trống.');
      return;
    }
    if (_optionControllers.any((c) => c.text.trim().isEmpty)) {
      _showError('Nội dung đáp án không được để trống.');
      return;
    }
    if (_correctOptionIndex == -1) {
      _showError('Vui lòng chọn một đáp án đúng.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final options = List<Map<String, dynamic>>.generate(
        _optionControllers.length,
        (index) => {
          'content': _optionControllers[index].text.trim(),
          'correct': index == _correctOptionIndex,
          'position': index + 1,
        },
      );

      final newQuestionData = {
        'content': _contentController.text.trim(),
        'type': 'MULTIPLE_CHOICE',
        'options': options,
      };

      await ref
          .read(questionServiceProvider)
          .createQuestion(newQuestionData, widget.examId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tạo câu hỏi thành công'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Pop with true to signal success
    } catch (e) {
      if (!mounted) return;
      _showError('Lỗi khi tạo câu hỏi: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _selectCorrectOption(int index) {
    setState(() {
      _correctOptionIndex = index;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

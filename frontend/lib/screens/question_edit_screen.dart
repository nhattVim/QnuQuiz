import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/models/media_file_model.dart';
import 'package:frontend/models/question_model.dart';
import 'package:frontend/models/question_option_model.dart';
import 'package:frontend/providers/service_providers.dart';
import 'package:frontend/widgets/media/media_list_viewer.dart';

class QuestionEditScreen extends ConsumerStatefulWidget {
  final QuestionModel question;
  const QuestionEditScreen({super.key, required this.question});

  @override
  ConsumerState<QuestionEditScreen> createState() => _QuestionEditScreenState();
}

class _QuestionEditScreenState extends ConsumerState<QuestionEditScreen> {
  // Controllers
  late TextEditingController _contentController;
  late List<TextEditingController> _optionControllers;
  late List<QuestionOptionModel> _options;

  // State
  int? _correctOptionId;
  QuestionModel? _updatedQuestion;
  List<MediaFileModel> _mediaFiles = [];
  bool _isLoadingMedia = false;
  bool _isUploadingFile = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context, null);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chỉnh sửa câu hỏi'),
          actions: [
            TextButton(onPressed: _cancelEdit, child: const Text('Hủy bỏ')),
            SizedBox(width: 8.w),
            OutlinedButton.icon(
              onPressed: _saveQuestion,
              icon: Icon(Icons.save_alt_outlined, size: 16.sp),
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
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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

              SizedBox(height: 16.h),
              // Media files section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Media files',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isUploadingFile ? null : _uploadMediaFile,
                    icon: _isUploadingFile
                        ? SizedBox(
                            width: 16.sp,
                            height: 16.sp,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(Icons.add, size: 16.sp),
                    label: const Text('Thêm media'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              // Show media files
              if (_isLoadingMedia)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_mediaFiles.isNotEmpty)
                MediaListViewer(
                  mediaFiles: _mediaFiles,
                  showDeleteButton: true,
                  onDelete: _deleteMediaFile,
                )
              else
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      'Chưa có media files. Nhấn "Thêm media" để thêm file.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),

              SizedBox(height: 24.h),

              Text(
                'Các đáp án',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 8.h),

              ...List.generate(_options.length, (index) {
                return _buildOptionEditor(
                  index: index,
                  option: _options[index],
                  controller: _optionControllers[index],
                );
              }),
            ],
          ),
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
    _contentController = TextEditingController(text: widget.question.content);
    _options = List.from(widget.question.options ?? []);
    _optionControllers = _options
        .map((option) => TextEditingController(text: option.content))
        .toList();
    _correctOptionId = _options
        .firstWhere(
          (option) => option.correct,
          orElse: () =>
              QuestionOptionModel(id: -1, content: '', correct: false),
        )
        .id;
    // Load media files
    _loadMediaFiles();
  }

  Future<void> _loadMediaFiles() async {
    if (widget.question.id == null) return;

    setState(() => _isLoadingMedia = true);
    try {
      final mediaFileService = ref.read(mediaFileServiceProvider);
      final mediaFilesData = await mediaFileService.getMediaFilesByQuestionId(
        widget.question.id!,
      );
      if (!mounted) return;
      setState(() {
        _mediaFiles = mediaFilesData
            .map((data) => MediaFileModel.fromJson(data))
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi tải media files: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoadingMedia = false);
      }
    }
  }

  Future<void> _uploadMediaFile() async {
    if (widget.question.id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Question ID không hợp lệ')));
      return;
    }

    setState(() => _isUploadingFile = true);
    try {
      final mediaFileService = ref.read(mediaFileServiceProvider);
      await mediaFileService.uploadMediaFileFromPicker(
        questionId: widget.question.id!,
        description: 'Media file for question',
      );
      if (!mounted) return;
      // Reload media files
      await _loadMediaFiles();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload file thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi upload file: $e')));
    } finally {
      if (mounted) {
        setState(() => _isUploadingFile = false);
      }
    }
  }

  Future<void> _deleteMediaFile(MediaFileModel media) async {
    if (media.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa file "${media.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final mediaFileService = ref.read(mediaFileServiceProvider);
      await mediaFileService.deleteMediaFile(media.id!);
      if (!mounted) return;
      // Reload media files
      await _loadMediaFiles();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa file thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa file: $e')));
    }
  }

  Widget _buildOptionEditor({
    required int index,
    required QuestionOptionModel option,
    required TextEditingController controller,
  }) {
    final theme = Theme.of(context);
    final isCorrect = option.id == _correctOptionId;

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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                TextButton.icon(
                  onPressed: () => _selectCorrectOption(option.id),
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

  void _cancelEdit() {
    Navigator.pop(context, null);
  }

  void _saveQuestion() async {
    final updatedOptions = List<QuestionOptionModel>.generate(_options.length, (
      index,
    ) {
      final oldOption = _options[index];
      return QuestionOptionModel(
        id: oldOption.id,
        content: _optionControllers[index].text.trim(),
        correct: oldOption.id == _correctOptionId,
      );
    });

    final updatedQuestion = QuestionModel(
      id: widget.question.id,
      content: _contentController.text.trim(),
      options: updatedOptions,
    );

    try {
      final result = await ref
          .read(questionServiceProvider)
          .updateQuestion(updatedQuestion);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật câu hỏi thành công'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _updatedQuestion = result;
      });
      Navigator.pop(context, _updatedQuestion);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi cập nhật câu hỏi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _selectCorrectOption(int? optionId) {
    if (optionId == null) return;
    setState(() {
      _correctOptionId = optionId;
    });
  }
}

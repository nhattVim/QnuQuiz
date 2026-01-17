import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/feedbacks/create_feedback_model.dart';
import 'package:frontend/models/feedbacks/feedback_template_model.dart';
import 'package:frontend/providers/service_providers.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  final int? examId;
  final String examTitle;
  final int? questionId;

  const FeedbackScreen({
    super.key,
    this.examId,
    required this.examTitle,
    this.questionId,
  });

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  int rating = 0;
  List<FeedbackTemplateModel> feedbackTemplates = [];
  List<String> selectedTemplates = [];
  final TextEditingController commentController = TextEditingController();
  bool _isSubmitting = false;
  bool isLoadingTemplates = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    try {
      final feedbackService = ref.read(feedbackServiceProvider);
      final templates = await feedbackService.getTemplates();
      setState(() {
        feedbackTemplates = templates;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải template: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void toggleTemplate(FeedbackTemplateModel template) {
    setState(() {
      if (selectedTemplates.contains(template.code)) {
        selectedTemplates.remove(template.code);
        // Xóa nội dung template khỏi comment
        String currentText = commentController.text;
        commentController.text = currentText
            .replaceAll(template.content, '')
            .trim();
      } else {
        selectedTemplates.add(template.code);
        // Thêm nội dung template vào comment
        if (commentController.text.isEmpty) {
          commentController.text = template.content;
        } else {
          commentController.text =
              '${commentController.text}\n${template.content}';
        }
      }
    });
  }

  Future<void> submitFeedback() async {
    // Validate rating
    if (rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn đánh giá sao'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate comment
    if (commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập bình luận'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Tạo model feedback với questionId nếu có
      final createFeedbackModel = CreateFeedbackModel(
        examId: widget.examId,
        questionId: widget.questionId,
        rating: rating,
        content: commentController.text.trim(),
      );

      // Gọi API để tạo feedback
      final feedbackService = ref.read(feedbackServiceProvider);
      await feedbackService.createFeedback(createFeedbackModel);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cảm ơn bạn đã gửi đánh giá!'),
            backgroundColor: Colors.green,
          ),
        );

        // Quay lại màn hình trước
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    widget.questionId != null
                        ? 'Đánh giá chi tiết câu hỏi'
                        : 'Đánh giá bài kiểm tra',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.arrow_back,
                        color: colorScheme.onSurface,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Rating section
                    Text(
                      'Trải nghiệm của bạn:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  rating = index + 1;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  Icons.star,
                                  size: 32,
                                  color: index < rating
                                      ? Colors.amber
                                      : colorScheme.outline.withValues(
                                          alpha: 0.5,
                                        ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$rating/5 sao',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Feedback tags section
                    Text(
                      'Mẫu trả lời nhanh:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    feedbackTemplates.isEmpty
                        ? const SizedBox(
                            height: 50,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: feedbackTemplates.map((template) {
                              bool isSelected = selectedTemplates.contains(
                                template.code,
                              );
                              return GestureDetector(
                                onTap: () => toggleTemplate(template),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: colorScheme.primary,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    color: isSelected
                                        ? colorScheme.primary.withValues(
                                            alpha: 0.2,
                                          )
                                        : Colors.transparent,
                                  ),
                                  child: Text(
                                    template.label,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 24),

                    // Comment section
                    Text(
                      'Bình luận',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: commentController,
                      maxLines: 6,
                      enabled: !_isSubmitting,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Hãy chia sẻ nhận xét của bạn!',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Submit button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Text(
                          'Gửi đánh giá',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

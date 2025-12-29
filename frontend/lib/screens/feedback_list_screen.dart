import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/feedbacks/feedback_dto.dart';
import 'package:frontend/providers/service_providers.dart';

class FeedbackListScreen extends ConsumerStatefulWidget {
  const FeedbackListScreen({super.key});

  @override
  ConsumerState<FeedbackListScreen> createState() => _FeedbackListScreenState();
}

class _FeedbackListScreenState extends ConsumerState<FeedbackListScreen> {
  final Map<String, List<FeedbackDto>> _groupedFeedbacks = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadFeedbacks());
  }

  Future<void> _loadFeedbacks() async {
    try {
      setState(() => _isLoading = true);
      final feedbackService = ref.read(feedbackServiceProvider);
      final feedbacks = await feedbackService.getFeedbacksByCurrentUser();

      // Group feedbacks by exam only
      _groupedFeedbacks.clear();
      for (var feedback in feedbacks) {
        final examKey = feedback.examContent;
        if (examKey.isNotEmpty) {
          if (!_groupedFeedbacks.containsKey(examKey)) {
            _groupedFeedbacks[examKey] = [];
          }
          _groupedFeedbacks[examKey]!.add(feedback);
        }
      }

      setState(() {
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Lỗi tải dữ liệu: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Đánh giá của tôi',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorWidget()
          : _groupedFeedbacks.isEmpty
          ? _buildEmptyWidget()
          : _buildFeedbackListView(),
    );
  }

  Widget _buildErrorWidget() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.error, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadFeedbacks,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feedback_outlined, size: 64, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'Chưa có đánh giá nào',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackListView() {
    final keys = _groupedFeedbacks.keys.toList();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final examKey = keys[index];
        final feedbackList = _groupedFeedbacks[examKey]!;

        return Column(
          children: [
            _buildExamSection(examKey, feedbackList),
            if (index < _groupedFeedbacks.length - 1)
              const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildExamSection(String examTitle, List<FeedbackDto> feedbacks) {
    return _ExamFeedbackSection(examTitle: examTitle, feedbacks: feedbacks);
  }
}

class _ExamFeedbackSection extends StatefulWidget {
  final String examTitle;
  final List<FeedbackDto> feedbacks;

  const _ExamFeedbackSection({
    required this.examTitle,
    required this.feedbacks,
  });

  @override
  State<_ExamFeedbackSection> createState() => _ExamFeedbackSectionState();
}

class _ExamFeedbackSectionState extends State<_ExamFeedbackSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Column(
        children: [
          // Exam Header
          GestureDetector(
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.examTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.feedbacks.length} đánh giá',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable Content
          if (_isExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.feedbacks.length,
                separatorBuilder: (context, index) => Divider(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                itemBuilder: (context, index) {
                  return _FeedbackItem(feedback: widget.feedbacks[index]);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _FeedbackItem extends StatelessWidget {
  final FeedbackDto feedback;

  const _FeedbackItem({required this.feedback});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isQuestionFeedback =
        feedback.questionContent != null &&
        feedback.questionContent != feedback.examContent;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question indicator if this is a question feedback
          if (isQuestionFeedback)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.help_outline_rounded,
                    size: 20,
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Câu hỏi: ${feedback.questionContent}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Header with user and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback.userName ?? 'Ẩn danh',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(feedback.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (isQuestionFeedback) _buildStatusBadge(feedback.status),
            ],
          ),

          const SizedBox(height: 12),

          // Rating
          if (feedback.rating != null)
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    size: 16,
                    color: index < (feedback.rating ?? 0)
                        ? Colors.amber
                        : colorScheme.outline.withValues(alpha: 0.5),
                  );
                }),
                const SizedBox(width: 8),
              ],
            ),

          const SizedBox(height: 12),

          // Content
          Text(
            feedback.content,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface,
              height: 1.5,
            ),
          ),

          // Teacher reply if exists
          if (feedback.reviewedBy != null && feedback.teacherReply != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.reply, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Phản hồi từ ${feedback.reviewedBy ?? 'Giáo viên'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feedback.teacherReply ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String statusText;

    switch (status.toUpperCase()) {
      case 'PENDING':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        statusText = 'Chờ xử lý';
        break;
      case 'REVIEWED':
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade700;
        statusText = 'Đã xem xét';
        break;
      case 'RESOLVED':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        statusText = 'Đã giải quyết';
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        statusText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

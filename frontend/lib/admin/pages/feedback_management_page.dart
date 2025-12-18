import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/feedbacks/feedback_dto.dart';
import 'package:frontend/providers/service_providers.dart';
import 'package:intl/intl.dart';

class FeedbackManagementPage extends ConsumerStatefulWidget {
  const FeedbackManagementPage({super.key});

  @override
  ConsumerState<FeedbackManagementPage> createState() =>
      _FeedbackManagementPageState();
}

class _FeedbackManagementPageState
    extends ConsumerState<FeedbackManagementPage> {
  late Future<List<FeedbackDto>> _feedbacksFuture;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _fetchFeedbacks();
  }

  void _fetchFeedbacks() {
    final feedbackService = ref.read(feedbackServiceProvider);
    setState(() {
      _feedbacksFuture = feedbackService.getAllFeedbacks();
    });
  }

  Future<void> _refresh() async {
    _fetchFeedbacks();
    await _feedbacksFuture;
  }

  void _confirmDeleteFeedback(int feedbackId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa đánh giá'),
        content: const Text('Bạn chắc chắn muốn xóa đánh giá này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final feedbackService = ref.read(feedbackServiceProvider);
              try {
                await feedbackService.deleteFeedback(feedbackId);
                if (!mounted) return;
                _fetchFeedbacks();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Xóa đánh giá thành công!')),
                );
                navigator.pop();
              } catch (e) {
                if (!mounted) return;
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Lỗi xóa đánh giá: $e')),
                );
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FilledButton.icon(
              onPressed: () => _refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tải lại'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<List<FeedbackDto>>(
            future: _feedbacksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return _ErrorState(
                  message: '${snapshot.error}',
                  onRetry: _fetchFeedbacks,
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const _EmptyState(message: 'Không có đánh giá nào.');
              }

              final feedbacks = snapshot.data!;
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Câu hỏi')),
                          DataColumn(label: Text('Nội dung')),
                          DataColumn(label: Text('Người dùng')),
                          DataColumn(label: Text('Sao')),
                          DataColumn(label: Text('Trạng thái')),
                          DataColumn(label: Text('Tạo lúc')),
                          DataColumn(label: Text('Hành động')),
                        ],
                        rows: feedbacks.map(_buildRow).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  DataRow _buildRow(FeedbackDto feedback) {
    return DataRow(
      cells: [
        DataCell(Text('${feedback.id ?? '-'}')),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(
              feedback.questionContent ?? 'Đánh giá chung',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              feedback.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(Text(feedback.userName ?? 'Ẩn danh')),
        DataCell(
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  size: 14,
                  color: index < (feedback.rating ?? 0)
                      ? Colors.amber
                      : Colors.grey.shade300,
                );
              }),
              const SizedBox(width: 4),
              Text('${feedback.rating ?? 0}'),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(feedback.status).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getStatusText(feedback.status),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _getStatusColor(feedback.status),
              ),
            ),
          ),
        ),
        DataCell(Text(_dateFormat.format(feedback.createdAt))),
        DataCell(
          IconButton(
            onPressed: feedback.id == null
                ? null
                : () => _confirmDeleteFeedback(feedback.id!),
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Xóa đánh giá',
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'REVIEWED':
        return Colors.blue;
      case 'RESOLVED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Chờ xử lý';
      case 'REVIEWED':
        return 'Đã xem';
      case 'RESOLVED':
        return 'Đã giải quyết';
      default:
        return status;
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox, size: 48),
          const SizedBox(height: 8),
          Text(message),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

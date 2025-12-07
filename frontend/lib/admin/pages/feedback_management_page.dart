import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/feedback_model.dart';
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
  late Future<List<FeedbackModel>> _feedbacksFuture;
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
        title: const Text('Delete Feedback'),
        content: const Text('Are you sure you want to delete this feedback?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
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
                  const SnackBar(content: Text('Feedback deleted successfully!')),
                );
                navigator.pop();
              } catch (e) {
                if (!mounted) return;
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Failed to delete feedback: $e')),
                );
              }
            },
            child: const Text('Delete'),
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
              label: const Text('Reload feedbacks'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<List<FeedbackModel>>(
            future: _feedbacksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return _ErrorState(message: '${snapshot.error}', onRetry: _fetchFeedbacks);
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const _EmptyState(message: 'No feedback found.');
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
                          DataColumn(label: Text('Subject')),
                          DataColumn(label: Text('Content')),
                          DataColumn(label: Text('User')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Created At')),
                          DataColumn(label: Text('Actions')),
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

  DataRow _buildRow(FeedbackModel feedback) {
    return DataRow(
      cells: [
        DataCell(Text('${feedback.id ?? '-'}')),
        DataCell(Text(feedback.subject ?? 'No subject')),
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
        DataCell(Text(feedback.user?.fullName ?? 'N/A')),
        DataCell(Text(feedback.userEmail ?? feedback.user?.email ?? '')),
        DataCell(Text(_dateFormat.format(feedback.createdAt))),
        DataCell(
          IconButton(
            onPressed: feedback.id == null
                ? null
                : () => _confirmDeleteFeedback(feedback.id!),
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete feedback',
          ),
        ),
      ],
    );
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
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

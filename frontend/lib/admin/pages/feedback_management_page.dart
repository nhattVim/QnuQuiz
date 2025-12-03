import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:frontend/models/feedback_model.dart';
import 'package:frontend/providers/service_providers.dart'; // Import service providers
import 'package:intl/intl.dart';

class FeedbackManagementPage extends ConsumerStatefulWidget { // Changed to ConsumerStatefulWidget
  const FeedbackManagementPage({super.key});

  @override
  ConsumerState<FeedbackManagementPage> createState() => _FeedbackManagementPageState();
}

class _FeedbackManagementPageState extends ConsumerState<FeedbackManagementPage> {
  // Removed direct instantiation:
  // final FeedbackService _feedbackService = FeedbackService();
  late Future<List<FeedbackModel>> _feedbacksFuture;

  @override
  void initState() {
    super.initState();
    _fetchFeedbacks();
  }

  void _fetchFeedbacks() {
    final feedbackService = ref.read(feedbackServiceProvider); // Get service from provider
    setState(() {
      _feedbacksFuture = feedbackService.getAllFeedbacks();
    });
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
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final feedbackService = ref.read(feedbackServiceProvider); // Get service from provider
              try {
                await feedbackService.deleteFeedback(feedbackId);
                _fetchFeedbacks();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Feedback deleted successfully!')),
                );
                navigator.pop();
              } catch (e) {
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
    return FutureBuilder<List<FeedbackModel>>(
      future: _feedbacksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No feedback found.'));
        }

        final feedbacks = snapshot.data!;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child:
              const Text('DataTable commented out temporarily in FeedbackManagementPage'),
        );
      },
    );
  }
}

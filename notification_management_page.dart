import 'package:flutter/material.dart';
import 'package:frontend/admin/widgets/notification_form_dialog.dart';
import 'package:frontend/models/notification_model.dart';
import 'package:frontend/services/notification_service.dart';
import 'package:intl/intl.dart';

class NotificationManagementPage extends StatefulWidget {
  const NotificationManagementPage({super.key});

  @override
  State<NotificationManagementPage> createState() => _NotificationManagementPageState();
}

class _NotificationManagementPageState extends State<NotificationManagementPage> {
  final NotificationService _notificationService = NotificationService();
  late Future<List<NotificationModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  void _fetchNotifications() {
    setState(() {
      _notificationsFuture = _notificationService.getAllNotifications();
    });
  }

  void _showNotificationFormDialog() {
    showDialog(
      context: context,
      builder: (context) => NotificationFormDialog(
        onSave: (newNotification) async {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          try {
            await _notificationService.createNotification(newNotification);
            _fetchNotifications();
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('Notification sent successfully!')),
            );
          } catch (e) {
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text('Failed to send notification: $e')),
            );
          }
        },
      ),
    );
  }

  void _confirmDeleteNotification(int notificationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              try {
                await _notificationService.deleteNotification(notificationId);
                _fetchNotifications();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                      content: Text('Notification deleted successfully!')),
                );
                navigator.pop();
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                      content: Text('Failed to delete notification: $e')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Management'),
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications found.'));
          }

          final notifications = snapshot.data!;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Body')),
                DataColumn(label: Text('Recipient Type')),
                DataColumn(label: Text('Recipient ID')),
                DataColumn(label: Text('Created At')),
                DataColumn(label: Text('Actions')),
              ],
              rows: notifications.map((notification) {
                return DataRow(
                  cells: <DataCell>[
                    DataCell(Text(notification.id.toString())),
                    DataCell(Text(notification.title)),
                    DataCell(SizedBox(
                      width: 200,
                      child: Text(notification.body, overflow: TextOverflow.ellipsis),
                    )),
                    DataCell(Text(notification.recipientType)),
                    DataCell(Text(notification.recipientId ?? 'ALL')),
                    DataCell(Text(DateFormat('yyyy-MM-dd HH:mm').format(notification.createdAt))),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _confirmDeleteNotification(notification.id!),
                        ),
                      ],
                    )),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNotificationFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

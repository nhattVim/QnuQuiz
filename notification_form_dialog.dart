import 'package:flutter/material.dart';
import 'package:frontend/models/notification_model.dart';

class NotificationFormDialog extends StatefulWidget {
  final Function(NotificationModel) onSave;

  const NotificationFormDialog({super.key, required this.onSave});

  @override
  State<NotificationFormDialog> createState() => _NotificationFormDialogState();
}

class _NotificationFormDialogState extends State<NotificationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late String _recipientType;
  late TextEditingController _recipientIdController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    _recipientType = 'ALL'; // Default recipient type
    _recipientIdController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _recipientIdController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newNotification = NotificationModel(
        title: _titleController.text,
        body: _bodyController.text,
        createdAt: DateTime.now(),
        recipientType: _recipientType,
        recipientId: _recipientIdController.text.isNotEmpty ? _recipientIdController.text : null,
      );
      widget.onSave(newNotification);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Notification'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: 'Body'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter notification body';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Recipient Type'),
                initialValue: _recipientType,
                items: ['ALL', 'STUDENT', 'TEACHER', 'CLASS', 'USER']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _recipientType = value;
                    });
                  }
                },
              ),
              if (_recipientType != 'ALL')
                TextFormField(
                  controller: _recipientIdController,
                  decoration: InputDecoration(labelText: 'Recipient ID (${_recipientType.toLowerCase()})'),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveForm,
          child: const Text('Send Notification'),
        ),
      ],
    );
  }
}

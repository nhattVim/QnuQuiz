import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:frontend/admin/widgets/user_form_dialog.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/providers/service_providers.dart'; // Import service providers

class UserManagementPage extends ConsumerStatefulWidget { // Changed to ConsumerStatefulWidget
  const UserManagementPage({super.key});

  @override
  ConsumerState<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends ConsumerState<UserManagementPage> {
  // Removed direct instantiation:
  // final UserService _userService = UserService();
  late Future<List<UserModel>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() {
    final userService = ref.read(userServiceProvider); // Get service from provider
    setState(() {
      _usersFuture = userService.getAllUsers();
    });
  }

  void _showUserFormDialog({UserModel? user}) {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(
        user: user,
        onSave: (newUser) async {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final userService = ref.read(userServiceProvider); // Get service from provider
          try {
            if (user == null) {
              await userService.createUser(newUser);
            } else {
              await userService.updateUser(newUser);
            }
            if (!mounted) return;
            _fetchUsers();
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('User saved successfully!')),
            );
          } catch (e) {
            if (!mounted) return;
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text('Failed to save user: $e')),
            );
          }
        },
      ),
    );
  }

  void _confirmDeleteUser(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final userService = ref.read(userServiceProvider); // Get service from provider
              try {
                await userService.deleteUser(userId);
                if (!mounted) return;
                _fetchUsers();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('User deleted successfully!')),
                );
                navigator.pop();
              } catch (e) {
                if (!mounted) return;
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Failed to delete user: $e')),
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
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () => _showUserFormDialog(),
              icon: const Icon(Icons.add),
              label: const Text('New user'),
            ),
            OutlinedButton.icon(
              onPressed: _fetchUsers,
              icon: const Icon(Icons.refresh),
              label: const Text('Reload'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<List<UserModel>>(
            future: _usersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No users found.'));
              }

              final users = snapshot.data!;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Username')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Role')),
                    DataColumn(label: Text('Full Name')),
                    DataColumn(label: Text('Phone Number')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: users.map((user) {
                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(user.id ?? '')),
                        DataCell(Text(user.username)),
                        DataCell(Text(user.email)),
                        DataCell(Text(user.role)),
                        DataCell(Text(user.fullName ?? '')),
                        DataCell(Text(user.phoneNumber ?? '')),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Edit user',
                              onPressed: () => _showUserFormDialog(user: user),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Delete user',
                              onPressed: user.id == null
                                  ? null
                                  : () => _confirmDeleteUser(user.id!),
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
        ),
      ],
    );
  }
}

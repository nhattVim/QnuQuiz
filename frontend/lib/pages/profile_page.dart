import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return SizedBox.expand(
      child: SafeArea(
        child: user == null
            ? const Center(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 60, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Không tìm thấy người dùng'),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.pink,
                      child: Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    _buildInfoCard(
                      'Tên người dùng',
                      user.username,
                      Icons.person,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard('Email', user.email, Icons.email),
                    const SizedBox(height: 12),
                    _buildInfoCard('Vai trò', user.role, Icons.badge),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.pink),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

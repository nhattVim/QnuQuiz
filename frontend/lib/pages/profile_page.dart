import 'package:flutter/material.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/services/user_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => Future.delayed(const Duration(seconds: 1)),
          child: FutureBuilder<UserModel?>(
            future: _loadUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || snapshot.data == null) {
                return Center(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          snapshot.hasError
                              ? 'Lỗi: ${snapshot.error}'
                              : 'Không tìm thấy người dùng',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              (context as Element).markNeedsBuild(),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final user = snapshot.data!;
              return SingleChildScrollView(
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
              );
            },
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

  Future<UserModel?> _loadUser() async {
    try {
      return await UserService().getUser();
    } catch (e) {
      return null;
    }
  }
}

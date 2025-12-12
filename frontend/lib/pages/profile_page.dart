import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/student_model.dart';
import 'package:frontend/models/teacher_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/pages/update_profile_page.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/service_providers.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:share_plus/share_plus.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  dynamic _profileData;
  bool _isLoadingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoadingProfile = true);
    try {
      final profile = await ref.read(userServiceProvider).getCurrentUserProfile();
      if (mounted) {
        setState(() {
          _profileData = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Hồ sơ của tôi',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text("User not found"));
          }

          // Get avatar URL from profile data or user
          String? avatarUrl;
          if (_profileData != null) {
            if (_profileData is StudentModel) {
              avatarUrl = (_profileData as StudentModel).avatarUrl;
            } else if (_profileData is TeacherModel) {
              avatarUrl = (_profileData as TeacherModel).avatarUrl;
            } else if (_profileData is UserModel) {
              avatarUrl = (_profileData as UserModel).avatarUrl;
            }
          }
          avatarUrl ??= user.avatarUrl;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Avatar
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.purple[200],
                  backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl) as ImageProvider
                      : null,
                  child: avatarUrl == null || avatarUrl.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 70,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                // Name
                Text(
                  user.fullName ?? user.username,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                // Username
                Text(
                  '@${user.username}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                // Update Profile Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UpdateProfilePage(),
                        ),
                      );
                      if (result == true) {
                        _loadProfile();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Cập nhật hồ sơ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Menu Options
                _buildMenuCard(
                  context,
                  children: [
                    _buildMenuTile(
                      context,
                      icon: Icons.settings_outlined,
                      title: 'Cài đặt',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tính năng đang phát triển'),
                          ),
                        );
                      },
                    ),
                    _buildMenuTile(
                      context,
                      icon: Icons.dark_mode_outlined,
                      title: 'Hiển thị',
                      onTap: () => _showThemeSelector(context),
                    ),
                    _buildMenuTile(
                      context,
                      icon: Icons.lock_outline,
                      title: 'Thay đổi mật khẩu',
                      onTap: () => _showChangePasswordDialog(context),
                    ),
                    _buildMenuTile(
                      context,
                      icon: Icons.share_outlined,
                      title: 'Chia sẻ hồ sơ',
                      onTap: () => _shareProfile(context, user),
                    ),
                    const Divider(height: 1),
                    _buildMenuTile(
                      context,
                      icon: Icons.help_outline,
                      title: 'Hỗ trợ và giúp đỡ',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tính năng đang phát triển'),
                          ),
                        );
                      },
                    ),
                    _buildMenuTile(
                      context,
                      icon: Icons.logout,
                      title: 'Đăng xuất',
                      onTap: () => _showLogoutDialog(context),
                      isDestructive: true,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.black87,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
        size: 20,
      ),
      onTap: onTap,
    );
  }

  void _showThemeSelector(BuildContext context) {
    final themeMode = ref.read(themeModeProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Chọn giao diện"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Theo hệ thống"),
              trailing: themeMode == ThemeMode.system
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                ref.read(themeModeProvider.notifier).state = ThemeMode.system;
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Chế độ sáng"),
              trailing: themeMode == ThemeMode.light
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                ref.read(themeModeProvider.notifier).state = ThemeMode.light;
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Chế độ tối"),
              trailing: themeMode == ThemeMode.dark
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
                Navigator.pop(context);
              },
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Thay đổi mật khẩu'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: oldPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu hiện tại',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu hiện tại';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: newPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu mới',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu mới';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Xác nhận mật khẩu mới',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng xác nhận mật khẩu';
                      }
                      if (value != newPasswordController.text) {
                        return 'Mật khẩu xác nhận không khớp';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading
                  ? null
                  : () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setState(() => isLoading = true);
                        try {
                          final user = ref.read(userProvider).value;
                          if (user == null) {
                            throw Exception('Không tìm thấy thông tin người dùng');
                          }

                          // Change password using dedicated API
                          switch (user.role) {
                            case 'STUDENT':
                              await ref.read(studentServiceProvider).changePassword(
                                    oldPassword: oldPasswordController.text,
                                    newPassword: newPasswordController.text,
                                  );
                              break;
                            case 'TEACHER':
                              await ref.read(teacherServiceProvider).changePassword(
                                    oldPassword: oldPasswordController.text,
                                    newPassword: newPasswordController.text,
                                  );
                              break;
                            case 'ADMIN':
                              await ref.read(userServiceProvider).changePassword(
                                    oldPassword: oldPasswordController.text,
                                    newPassword: newPasswordController.text,
                                  );
                              break;
                          }

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đổi mật khẩu thành công'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            String errorMessage = 'Lỗi đổi mật khẩu';
                            if (e is Exception) {
                              final message = e.toString().replaceAll('Exception: ', '');
                              if (message.isNotEmpty) {
                                errorMessage = message;
                              }
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            setState(() => isLoading = false);
                          }
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Đổi mật khẩu'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _shareProfile(BuildContext context, UserModel user) {
    final profileText = '''
Hồ sơ của tôi trên QnuQuiz:
Tên: ${user.fullName ?? user.username}
Username: @${user.username}
Email: ${user.email ?? 'Chưa cập nhật'}
''';
    Share.share(profileText);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/class_model.dart';
import 'package:frontend/models/department_model.dart';
import 'package:frontend/models/student_model.dart';
import 'package:frontend/models/teacher_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/providers/service_providers.dart';
import 'package:frontend/providers/user_provider.dart';

class UpdateProfilePage extends ConsumerStatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  ConsumerState<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends ConsumerState<UpdateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isUploadingAvatar = false;
  dynamic _profileData;
  String? _currentAvatarUrl;
  File? _selectedAvatarFile;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final user = ref.read(userProvider).value;
    if (user == null) return;

    try {
      final profile = await ref
          .read(userServiceProvider)
          .getCurrentUserProfile();
      setState(() {
        _profileData = profile;
        if (profile is StudentModel) {
          _currentAvatarUrl = profile.avatarUrl;
        } else if (profile is TeacherModel) {
          _currentAvatarUrl = profile.avatarUrl;
        } else if (profile is UserModel) {
          _currentAvatarUrl = profile.avatarUrl;
        }
      });

      _fullNameController.text = _profileData.fullName ?? '';
      _usernameController.text = _profileData.username ?? '';
      _phoneNumberController.text = _profileData.phoneNumber ?? '';
      _emailController.text = _profileData.email ?? '';
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<void> _pickAvatar() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedAvatarFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = ref.read(userProvider).value;
    if (user == null) return;

    try {
      String? newAvatarUrl = _currentAvatarUrl;

      // Upload new avatar if selected
      if (_selectedAvatarFile != null) {
        setState(() {
          _isUploadingAvatar = true;
        });

        try {
          // Delete old avatar from Appwrite if exists
          if (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty) {
            try {
              await ref.read(appwriteServiceProvider).deleteFileByUrl(_currentAvatarUrl);
            } catch (e) {
              // Log but continue even if deletion fails
              debugPrint('Failed to delete old avatar: $e');
            }
          }

          // Upload new avatar
          newAvatarUrl = await ref.read(appwriteServiceProvider).uploadFile(
                file: _selectedAvatarFile!,
                fileName: 'avatar_${user.username}_${DateTime.now().millisecondsSinceEpoch}.jpg',
              );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi khi upload avatar: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() {
            _isLoading = false;
            _isUploadingAvatar = false;
          });
          return;
        } finally {
          setState(() {
            _isUploadingAvatar = false;
          });
        }
      }

      // Update profile with new avatar URL
      switch (user.role) {
        case 'STUDENT':
          if (_profileData is StudentModel) {
            final student = _profileData as StudentModel;
            await ref.read(studentServiceProvider).updateProfile(
                  fullName: _fullNameController.text.trim(),
                  email: _emailController.text.trim(),
                  phoneNumber: _phoneNumberController.text.trim(),
                  departmentId: student.departmentId,
                  classId: student.classId,
                  avatarUrl: newAvatarUrl,
                );
          }
          break;
        case 'TEACHER':
          if (_profileData is TeacherModel) {
            final teacher = _profileData as TeacherModel;
            await ref.read(teacherServiceProvider).updateProfile(
                  fullName: _fullNameController.text.trim(),
                  email: _emailController.text.trim(),
                  phoneNumber: _phoneNumberController.text.trim(),
                  departmentId: teacher.departmentId,
                  title: teacher.title,
                  avatarUrl: newAvatarUrl,
                );
          }
          break;
        case 'ADMIN':
          await ref.read(userServiceProvider).updateProfile(
                fullName: _fullNameController.text.trim(),
                email: _emailController.text.trim(),
                phoneNumber: _phoneNumberController.text.trim(),
                avatarUrl: newAvatarUrl,
              );
          break;
      }

      final updatedUser = user.copyWith(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        avatarUrl: newAvatarUrl,
      );
      ref.read(userProvider.notifier).setUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật hồ sơ thành công'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cập nhật hồ sơ',
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

          // Determine which avatar to show
          final displayAvatarUrl = _selectedAvatarFile != null
              ? null // Will show placeholder when file is selected
              : (_currentAvatarUrl ?? user.avatarUrl);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Avatar with camera icon
                  GestureDetector(
                    onTap: _isLoading ? null : _pickAvatar,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.pink[300],
                          backgroundImage: _selectedAvatarFile != null
                              ? FileImage(_selectedAvatarFile!)
                              : (displayAvatarUrl != null && displayAvatarUrl.isNotEmpty
                                  ? NetworkImage(displayAvatarUrl)
                                  : null),
                          child: (_selectedAvatarFile == null &&
                                  (displayAvatarUrl == null || displayAvatarUrl.isEmpty))
                              ? const Icon(
                                  Icons.person,
                                  size: 70,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: _isUploadingAvatar
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.fullName ?? user.username,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${user.username}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  // Full Name
                  _buildTextFormField(
                    _fullNameController,
                    'Họ và tên',
                    Icons.person_outline,
                  ),
                  const SizedBox(height: 16),

                  // Username and Phone Number in Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextFormField(
                          _usernameController,
                          'Tên đăng nhập',
                          Icons.account_circle_outlined,
                          enabled: false,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextFormField(
                          _phoneNumberController,
                          'Số điện thoại',
                          Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Email
                  _buildTextFormField(
                    _emailController,
                    'Email',
                    Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Show read-only department/class info for students
                  if (user.role == 'STUDENT' && _profileData is StudentModel)
                    _buildReadOnlyInfo(user, _profileData as StudentModel),

                  // Show read-only department/title info for teachers
                  if (user.role == 'TEACHER' && _profileData is TeacherModel)
                    _buildReadOnlyInfo(user, _profileData as TeacherModel),

                  const SizedBox(height: 16),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (_isLoading || _isUploadingAvatar) ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Lưu hồ sơ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: const TextStyle(fontSize: 16),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập $label';
        }
        if (label == 'Email' && !value.contains('@')) {
          return 'Email không hợp lệ';
        }
        return null;
      },
    );
  }

  Widget _buildReadOnlyInfo(UserModel user, dynamic profile) {
    if (user.role == 'STUDENT' && profile is StudentModel) {
      return FutureBuilder<List<DepartmentModel>>(
        future: ref.read(departmentServiceProvider).getAllDepartments(),
        builder: (context, deptSnapshot) {
          String deptName = 'Chưa cập nhật';
          if (deptSnapshot.hasData && 
              profile.departmentId != null && 
              deptSnapshot.data!.isNotEmpty) {
            try {
              final dept = deptSnapshot.data!.firstWhere(
                (d) => d.id == profile.departmentId,
              );
              deptName = dept.name;
            } catch (e) {
              deptName = 'Chưa cập nhật';
            }
          }

          return FutureBuilder<List<ClassModel>>(
            future: profile.departmentId != null
                ? ref
                    .read(classServiceProvider)
                    .getClassesByDepartment(profile.departmentId!)
                : Future.value(<ClassModel>[]),
            builder: (context, classSnapshot) {
              String className = 'Chưa cập nhật';
              if (classSnapshot.hasData && 
                  profile.classId != null && 
                  classSnapshot.data!.isNotEmpty) {
                try {
                  final cls = classSnapshot.data!.firstWhere(
                    (c) => c.id == profile.classId,
                  );
                  className = cls.name;
                } catch (e) {
                  className = 'Chưa cập nhật';
                }
              }

              return Column(
                children: [
                  _buildReadOnlyField('Khoa', deptName, Icons.school_outlined),
                  const SizedBox(height: 16),
                  _buildReadOnlyField('Lớp', className, Icons.class_outlined),
                ],
              );
            },
          );
        },
      );
    } else if (user.role == 'TEACHER' && profile is TeacherModel) {
      return FutureBuilder<List<DepartmentModel>>(
        future: ref.read(departmentServiceProvider).getAllDepartments(),
        builder: (context, snapshot) {
          String deptName = 'Chưa cập nhật';
          String title = profile.title ?? 'Chưa cập nhật';
          if (snapshot.hasData && 
              profile.departmentId != null && 
              snapshot.data!.isNotEmpty) {
            try {
              final dept = snapshot.data!.firstWhere(
                (d) => d.id == profile.departmentId,
              );
              deptName = dept.name;
            } catch (e) {
              deptName = 'Chưa cập nhật';
            }
          }

          return Column(
            children: [
              _buildReadOnlyField('Khoa', deptName, Icons.school_outlined),
              const SizedBox(height: 16),
              _buildReadOnlyField('Chức danh', title, Icons.work_outline),
            ],
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

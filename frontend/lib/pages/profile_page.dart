import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/student_model.dart';
import 'package:frontend/models/teacher_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/services/student_service.dart';
import 'package:frontend/services/department_service.dart';
import 'package:frontend/services/class_service.dart';
import 'package:frontend/models/department_model.dart';
import 'package:frontend/models/class_model.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/services/teacher_service.dart';
import 'package:frontend/services/user_service.dart';
// Thêm import màn hình lịch sử nếu có
import 'package:frontend/screens/student_exam_history_screen.dart'; 

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _titleController = TextEditingController();
  final _teacherCodeController = TextEditingController();

  final _studentService = StudentService();
  final _teacherService = TeacherService();
  final _departmentService = DepartmentService();
  final _classService = ClassService();
  final _userService = UserService();

  bool _isLoading = false;
  dynamic _profileData;

  List<DepartmentModel> _departments = [];
  List<ClassModel> _classes = [];
  int? _selectedDepartmentId;
  int? _selectedClassId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final user = ref.read(userProvider);
    if (user == null) return;

    await _loadDepartments();

    try {
      final profile = await _userService.getCurrentUserProfile();
      setState(() {
        _profileData = profile;
      });

      _fullNameController.text = _profileData.fullName ?? '';
      _usernameController.text = _profileData.username ?? '';
      _phoneNumberController.text = _profileData.phoneNumber ?? '';
      _emailController.text = _profileData.email ?? '';

      if (profile is StudentModel) {
        if (profile.departmentId != null) {
          setState(() {
            _selectedDepartmentId = profile.departmentId;
          });
          await _loadClasses(profile.departmentId!);
          if (profile.classId != null) {
            setState(() {
              _selectedClassId = profile.classId;
            });
          }
        }
      } else if (profile is TeacherModel) {
        _titleController.text = profile.title ?? '';
        _teacherCodeController.text = profile.teacherCode ?? '';
        if (profile.departmentId != null) {
          setState(() {
            _selectedDepartmentId = profile.departmentId;
          });
        }
      }
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<void> _loadDepartments() async {
    try {
      final departments = await _departmentService.getAllDepartments();
      setState(() {
        _departments = departments;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadClasses(int departmentId) async {
    setState(() {
      _selectedClassId = null;
    });
    try {
      final classes = await _classService.getClassesByDepartment(departmentId);
      setState(() {
        _classes = classes;
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _titleController.dispose();
    _teacherCodeController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = ref.read(userProvider);
    if (user == null) return;

    try {
      dynamic updatedProfile;
      switch (user.role) {
        case 'STUDENT':
          if (_selectedDepartmentId == null || _selectedClassId == null) {
            throw Exception('Vui lòng chọn khoa và lớp');
          }
          updatedProfile = await _studentService.updateProfile(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            phoneNumber: _phoneNumberController.text.trim(),
            departmentId: _selectedDepartmentId,
            classId: _selectedClassId,
          );
          break;
        case 'TEACHER':
          if (_selectedDepartmentId == null) {
            throw Exception('Vui lòng chọn khoa');
          }
          updatedProfile = await _teacherService.updateProfile(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            phoneNumber: _phoneNumberController.text.trim(),
            departmentId: _selectedDepartmentId,
            title: _titleController.text.trim(),
          );
          break;
        case 'ADMIN':
          updatedProfile = await _userService.updateProfile(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            phoneNumber: _phoneNumberController.text.trim(),
          );
          break;
      }

      final updatedUser = user.copyWith(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
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
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
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
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
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
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Avatar
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.pink[300],
                          child: const Icon(
                            Icons.person,
                            size: 70,
                            color: Colors.white,
                          ),
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
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.fullName ?? user.username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${user.username}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),

                    // Common Fields
                    _buildTextFormField(
                      _fullNameController,
                      'Họ và tên',
                      Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      _usernameController,
                      'Tên đăng nhập',
                      Icons.account_circle_outlined,
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      _phoneNumberController,
                      'Số điện thoại',
                      Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      _emailController,
                      'Email',
                      Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Role-specific fields
                    _buildRoleSpecificFields(user),

                    // Nút "Lịch sử làm bài thi" chỉ dành cho STUDENT
                    if (user.role == 'STUDENT') ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const StudentExamHistoryScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.history),
                          label: const Text(
                            'Lịch sử làm bài thi',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
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
                    const SizedBox(height: 16),
                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
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
                        icon: const Icon(Icons.logout),
                        label: const Text('Đăng xuất'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
      ),
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

  Widget _buildDepartmentDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<int>(
        initialValue: _selectedDepartmentId,
        decoration: const InputDecoration(
          labelText: 'Khoa',
          prefixIcon: Icon(Icons.school_outlined),
          border: InputBorder.none,
        ),
        items: _departments.map((dept) {
          return DropdownMenuItem<int>(value: dept.id, child: Text(dept.name));
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedDepartmentId = value;
          });
          final user = ref.read(userProvider);
          if (value != null && user?.role == 'STUDENT') {
            _loadClasses(value);
          }
        },
        validator: (value) => value == null ? 'Vui lòng chọn khoa' : null,
      ),
    );
  }

  Widget _buildRoleSpecificFields(UserModel user) {
    switch (user.role) {
      case 'TEACHER':
        return Column(
          children: [
            _buildTextFormField(
              _teacherCodeController,
              'Mã giảng viên',
              Icons.qr_code_scanner_outlined,
              enabled: false,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              _titleController,
              'Chức danh',
              Icons.school_outlined,
            ),
            const SizedBox(height: 16),
            _buildDepartmentDropdown(),
          ],
        );
      case 'STUDENT':
        return Column(
          children: [
            _buildDepartmentDropdown(),
            const SizedBox(height: 16),
            _buildClassDropdown(),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildClassDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<int>(
        initialValue: _selectedClassId,
        decoration: const InputDecoration(
          labelText: 'Lớp',
          prefixIcon: Icon(Icons.class_outlined),
          border: InputBorder.none,
        ),
        items: _classes.map((cls) {
          return DropdownMenuItem<int>(value: cls.id, child: Text(cls.name));
        }).toList(),
        onChanged: _selectedDepartmentId == null
            ? null
            : (value) {
                setState(() {
                  _selectedClassId = value;
                });
              },
        validator: (value) => value == null ? 'Vui lòng chọn lớp' : null,
      ),
    );
  }
}

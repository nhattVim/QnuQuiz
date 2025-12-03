import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/models/class_model.dart';
import 'package:frontend/models/department_model.dart';
import 'package:frontend/providers/service_providers.dart';

class CreateNotificationScreen extends ConsumerStatefulWidget {
  const CreateNotificationScreen({super.key});

  @override
  ConsumerState<CreateNotificationScreen> createState() => _CreateNotificationScreenState();
}

class _CreateNotificationScreenState extends ConsumerState<CreateNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedTarget; // ALL, DEPARTMENT, CLASS
  int? _selectedClassId;
  int? _selectedDepartmentId;
  List<ClassModel> _classes = [];
  List<DepartmentModel> _departments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final classes = await ref.read(classServiceProvider).getAllClasses();
      final departments = await ref.read(departmentServiceProvider).getAllDepartments();
      setState(() {
        _classes = classes;
        _departments = departments;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTarget == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn loại thông báo')),
      );
      return;
    }

    // Validate theo loại thông báo
    if (_selectedTarget == 'CLASS' && _selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn lớp')),
      );
      return;
    }

    if (_selectedTarget == 'DEPARTMENT' && _selectedDepartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn khoa')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(announcementServiceProvider).createAnnouncement(
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            target: _selectedTarget!,
            classId: _selectedTarget == 'CLASS' ? _selectedClassId : null,
            departmentId: _selectedTarget == 'DEPARTMENT' ? _selectedDepartmentId : null,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo thông báo thành công')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}')),
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
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo thông báo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // Target type selection
            DropdownButtonFormField<String>(
              value: _selectedTarget,
              decoration: InputDecoration(
                labelText: 'Loại thông báo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              items: const [
                DropdownMenuItem<String>(
                  value: 'ALL',
                  child: Text('Toàn trường'),
                ),
                DropdownMenuItem<String>(
                  value: 'DEPARTMENT',
                  child: Text('Khoa'),
                ),
                DropdownMenuItem<String>(
                  value: 'CLASS',
                  child: Text('Lớp'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTarget = value;
                  _selectedClassId = null;
                  _selectedDepartmentId = null;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Vui lòng chọn loại thông báo';
                }
                return null;
              },
            ),

            SizedBox(height: 16.h),

            // Department selection (only for DEPARTMENT target)
            if (_selectedTarget == 'DEPARTMENT')
              DropdownButtonFormField<int>(
                value: _selectedDepartmentId,
                decoration: InputDecoration(
                  labelText: 'Chọn khoa',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                items: _departments.map((dept) {
                  return DropdownMenuItem<int>(
                    value: dept.id,
                    child: Text(dept.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDepartmentId = value;
                  });
                },
                validator: (value) {
                  if (_selectedTarget == 'DEPARTMENT' && value == null) {
                    return 'Vui lòng chọn khoa';
                  }
                  return null;
                },
              ),

            if (_selectedTarget == 'DEPARTMENT') SizedBox(height: 16.h),

            // Class selection (only for CLASS target)
            if (_selectedTarget == 'CLASS')
              DropdownButtonFormField<int>(
                value: _selectedClassId,
                decoration: InputDecoration(
                  labelText: 'Chọn lớp',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                items: _classes.map((classItem) {
                  return DropdownMenuItem<int>(
                    value: classItem.id,
                    child: Text(classItem.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClassId = value;
                  });
                },
                validator: (value) {
                  if (_selectedTarget == 'CLASS' && value == null) {
                    return 'Vui lòng chọn lớp';
                  }
                  return null;
                },
              ),

            if (_selectedTarget == 'CLASS') SizedBox(height: 16.h),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Tiêu đề',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tiêu đề';
                }
                return null;
              },
            ),

            SizedBox(height: 16.h),

            // Content
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Nội dung',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập nội dung';
                }
                return null;
              },
            ),

            SizedBox(height: 24.h),

            // Submit button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Tạo thông báo'),
            ),
          ],
        ),
      ),
    );
  }
}


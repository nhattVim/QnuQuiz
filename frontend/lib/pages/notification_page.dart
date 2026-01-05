import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/models/announcement_model.dart';
import 'package:frontend/models/student_model.dart';
import 'package:frontend/models/teacher_model.dart';
import 'package:frontend/providers/service_providers.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/screens/notification/create_notification_screen.dart';
import 'package:frontend/screens/notification/notification_detail_screen.dart';
import 'package:intl/intl.dart';

enum NotificationFilter {
  all,
  department,
  class_,
}

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  Future<List<AnnouncementModel>>? _announcementsFuture;
  NotificationFilter _selectedFilter = NotificationFilter.all;
  int? _userDepartmentId;
  int? _userClassId;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = ref.read(userProvider).value;
      if (user != null) {
        setState(() {
          _userRole = user.role;
        });

        final profile = await ref
            .read(userServiceProvider)
            .getCurrentUserProfile();
        if (profile is StudentModel) {
          setState(() {
            _userDepartmentId = profile.departmentId;
            _userClassId = profile.classId;
          });
        } else if (profile is TeacherModel) {
          setState(() {
            _userDepartmentId = profile.departmentId;
          });
        }
      }
      _loadAnnouncements();
    } catch (e) {
      // Handle error if needed
      _loadAnnouncements();
    }
  }

  void _loadAnnouncements() {
    if (_userRole == null) {
      // Initialize with empty list if role is not available
      setState(() {
        _announcementsFuture = Future.value(<AnnouncementModel>[]);
      });
      return;
    }
    setState(() {
      _announcementsFuture = ref.read(announcementServiceProvider).getAnnouncements(role: _userRole!);
    });
  }

  List<AnnouncementModel> _filterAnnouncements(List<AnnouncementModel> announcements) {
    final isStudent = _userRole == 'STUDENT';
    
    switch (_selectedFilter) {
      case NotificationFilter.all:
        if (isStudent) {
          // Student: hiển thị ALL + DEPARTMENT của mình + CLASS của mình
          return announcements.where((a) {
            if (a.target == 'ALL') return true;
            if (a.target == 'DEPARTMENT' && a.departmentId == _userDepartmentId) return true;
            if (a.target == 'CLASS' && a.classId == _userClassId) return true;
            return false;
          }).toList();
        } else {
          // Teacher/Admin: hiển thị tất cả
          return announcements;
        }
      case NotificationFilter.department:
        if (isStudent) {
          // Student: chỉ hiển thị DEPARTMENT của mình
          if (_userDepartmentId == null) return [];
          return announcements
              .where((a) =>
                  a.target == 'DEPARTMENT' && a.departmentId == _userDepartmentId)
              .toList();
        } else {
          // Teacher/Admin: hiển thị tất cả các khoa
          return announcements
              .where((a) => a.target == 'DEPARTMENT')
              .toList();
        }
      case NotificationFilter.class_:
        if (isStudent) {
          // Student: chỉ hiển thị CLASS của mình
          if (_userClassId == null) return [];
          return announcements
              .where((a) =>
                  a.target == 'CLASS' && a.classId == _userClassId)
              .toList();
        } else {
          // Teacher/Admin: hiển thị tất cả các lớp
          return announcements
              .where((a) => a.target == 'CLASS')
              .toList();
        }
    }
  }

  Future<void> _handleDelete(int id) async {
    try {
      await ref.read(announcementServiceProvider).deleteAnnouncement(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa thông báo')),
        );
        _loadAnnouncements();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    }
  }

  Future<void> _handleDeleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn xóa tất cả thông báo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(announcementServiceProvider).deleteAllAnnouncements();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa tất cả thông báo')),
          );
          _loadAnnouncements();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}')),
          );
        }
      }
    }
  }

  Future<void> _handleCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateNotificationScreen()),
    );
    if (result == true) {
      _loadAnnouncements();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isTeacher = _userRole == 'TEACHER' || _userRole == 'ADMIN';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        automaticallyImplyLeading: false,
        title: Text(
          'Thông báo',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      context,
                      label: 'Tất cả',
                      filter: NotificationFilter.all,
                      theme: theme,
                    ),
                    SizedBox(width: 8.w),
                    _buildFilterChip(
                      context,
                      label: 'Khoa',
                      filter: NotificationFilter.department,
                      theme: theme,
                    ),
                    SizedBox(width: 8.w),
                    _buildFilterChip(
                      context,
                      label: 'Lớp',
                      filter: NotificationFilter.class_,
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ),

            // Announcements list
            Expanded(
              child: _announcementsFuture == null
                  ? const Center(child: CircularProgressIndicator())
                  : FutureBuilder<List<AnnouncementModel>>(
                      future: _announcementsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                          SizedBox(height: 16.h),
                          Text(
                            'Lỗi tải dữ liệu',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            snapshot.error.toString().replaceAll('Exception: ', ''),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 24.h),
                          ElevatedButton.icon(
                            onPressed: _loadAnnouncements,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Chưa có thông báo',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final allAnnouncements = snapshot.data!;
                  final filteredAnnouncements = _filterAnnouncements(allAnnouncements);

                  if (filteredAnnouncements.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.filter_list_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Không có thông báo cho bộ lọc này',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadAnnouncements(),
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      itemCount: filteredAnnouncements.length,
                      itemBuilder: (context, index) {
                        final announcement = filteredAnnouncements[index];
                        return _buildAnnouncementCard(
                          announcement,
                          dateFormat,
                          theme,
                          isTeacher: isTeacher,
                        );
                      },
                    ),
                  );
                },
              ),
                    ),

            // Action buttons (only for teachers) - ở dưới danh sách
            if (isTeacher) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleCreate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: const Text('Tạo thông báo'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleDeleteAll,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: const Text('Xoá tất cả'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required NotificationFilter filter,
    required ThemeData theme,
  }) {
    final isSelected = _selectedFilter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = filter;
          });
        }
      },
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildAnnouncementCard(
    AnnouncementModel announcement,
    DateFormat dateFormat,
    ThemeData theme, {
    required bool isTeacher,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationDetailScreen(
                announcement: announcement,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and delete button (only for teachers)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateFormat.format(announcement.publishedAt),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isTeacher)
                    IconButton(
                      onPressed: () => _handleDelete(announcement.id),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      iconSize: 20.sp,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Xóa',
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              // Title
              Text(
                announcement.title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (announcement.target == 'DEPARTMENT' && announcement.departmentName != null) ...[
                SizedBox(height: 4.h),
                Text(
                  'Khoa: ${announcement.departmentName}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              if (announcement.target == 'CLASS' && announcement.className != null) ...[
                SizedBox(height: 4.h),
                Text(
                  'Lớp: ${announcement.className}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

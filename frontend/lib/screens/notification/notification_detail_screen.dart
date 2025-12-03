import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/models/announcement_model.dart';
import 'package:intl/intl.dart';

class NotificationDetailScreen extends StatelessWidget {
  final AnnouncementModel announcement;

  const NotificationDetailScreen({
    super.key,
    required this.announcement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết thông báo'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              announcement.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
            ),
            SizedBox(height: 16.h),

            // Metadata
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 8.w),
                Text(
                  dateFormat.format(announcement.publishedAt),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (announcement.authorName != null) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.person, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 8.w),
                  Text(
                    'Người đăng: ${announcement.authorName}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
            if (announcement.className != null) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.class_, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 8.w),
                  Text(
                    'Lớp: ${announcement.className}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
            if (announcement.departmentName != null) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.school, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 8.w),
                  Text(
                    'Khoa: ${announcement.departmentName}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 24.h),

            // Content
            Text(
              'Nội dung',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                announcement.content,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[900],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


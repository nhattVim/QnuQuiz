import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/services/analytics_service.dart';
import 'package:frontend/services/announcement_service.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/class_service.dart';
import 'package:frontend/services/department_service.dart';
import 'package:frontend/services/exam_history_service.dart';
import 'package:frontend/services/exam_service.dart';
import 'package:frontend/services/feedback_service.dart';
import 'package:frontend/services/health_service.dart';
import 'package:frontend/services/question_service.dart';
import 'package:frontend/services/student_service.dart';
import 'package:frontend/services/teacher_service.dart';
import 'package:frontend/services/user_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(ref.watch(apiServiceProvider));
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(apiServiceProvider));
});

final classServiceProvider = Provider<ClassService>((ref) {
  return ClassService(ref.watch(apiServiceProvider));
});

final departmentServiceProvider = Provider<DepartmentService>((ref) {
  return DepartmentService(ref.watch(apiServiceProvider));
});

final examHistoryServiceProvider = Provider<ExamHistoryService>((ref) {
  return ExamHistoryService(ref.watch(apiServiceProvider));
});

final examServiceProvider = Provider<ExamService>((ref) {
  return ExamService(ref.watch(apiServiceProvider));
});

final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  return FeedbackService(ref.watch(apiServiceProvider));
});

final healthServiceProvider = Provider<HealthService>((ref) {
  return HealthService(ref.watch(apiServiceProvider));
});

final questionServiceProvider = Provider<QuestionService>((ref) {
  return QuestionService(ref.watch(apiServiceProvider));
});

final studentServiceProvider = Provider<StudentService>((ref) {
  return StudentService(ref.watch(apiServiceProvider));
});

final teacherServiceProvider = Provider<TeacherService>((ref) {
  return TeacherService(ref.watch(apiServiceProvider));
});

final userServiceProvider = Provider<UserService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UserService(apiService);
});

final announcementServiceProvider = Provider<AnnouncementService>((ref) {
  return AnnouncementService(ref.watch(apiServiceProvider));
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exam_category_model.dart';
import 'package:frontend/models/exam_history_model.dart';
import 'package:frontend/models/student_model.dart';
import 'package:frontend/providers/service_providers.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/widgets/dashboard/action_card.dart';
import 'package:frontend/widgets/dashboard/category_section.dart';
import 'package:frontend/widgets/dashboard/greeting_section.dart';
import 'package:frontend/widgets/dashboard/recent_section.dart';
import 'package:frontend/widgets/dashboard/search_bar.dart';

final currentUserProfileProvider = FutureProvider.autoDispose<dynamic>((
  ref,
) async {
  final userService = ref.watch(userServiceProvider);
  return await userService.getCurrentUserProfile();
});

final categoriesProvider = FutureProvider.autoDispose<List<ExamCategoryModel>>((
  ref,
) async {
  final examService = ref.watch(examServiceProvider);
  return await examService.getAllCategories();
});

final allExamHistoryProvider =
    FutureProvider.autoDispose<List<ExamHistoryModel>>((ref) async {
      // Chỉ gọi API cho sinh viên
      final user = ref.watch(userProvider).value;
      if (user == null || user.role != 'STUDENT') {
        return <ExamHistoryModel>[];
      }
      
      try {
        final examHistoryService = ref.watch(examHistoryServiceProvider);
        return await examHistoryService.getExamHistory();
      } catch (e) {
        // Nếu có lỗi (403, etc), return empty list thay vì throw error
        return <ExamHistoryModel>[];
      }
    });

final recentExamHistoryProvider =
    FutureProvider.autoDispose<List<ExamHistoryModel>>((ref) async {
      final allHistory = await ref.watch(allExamHistoryProvider.future);
      final history = List<ExamHistoryModel>.from(allHistory);
      history.sort((a, b) {
        if (a.completionDate == null && b.completionDate == null) return 0;
        if (a.completionDate == null) return 1;
        if (b.completionDate == null) return -1;
        return b.completionDate!.compareTo(a.completionDate!);
      });
      return history.take(5).toList();
    });

final totalPointsProvider = FutureProvider.autoDispose<int>((ref) async {
  final allHistory = await ref.watch(allExamHistoryProvider.future);

  double totalScore = 0;
  for (var history in allHistory) {
    if (history.score != null) {
      totalScore += history.score!;
    }
  }

  return totalScore.round();
});

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final recentHistoryAsync = ref.watch(recentExamHistoryProvider);
    final totalPointsAsync = ref.watch(totalPointsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(currentUserProfileProvider);
            ref.invalidate(categoriesProvider);
            ref.invalidate(allExamHistoryProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Section với thông tin user từ API
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: userProfileAsync.when(
                    data: (profile) {
                      String username = "Người dùng";
                      String? avatarUrl;

                      if (profile is StudentModel) {
                        String fullName =
                            profile.fullName ??
                            profile.username ??
                            "Người dùng";
                        username = _getFirstName(fullName);
                        avatarUrl = profile.avatarUrl;
                      } else if (profile != null) {
                        String fullName =
                            profile.fullName ??
                            profile.username ??
                            "Người dùng";
                        username = _getFirstName(fullName);
                        avatarUrl = profile.avatarUrl;
                      }

                      // Lấy points từ totalPointsProvider
                      return totalPointsAsync.when(
                        data: (points) => GreetingSection(
                          username: username,
                          avatarUrl: avatarUrl,
                          points: points,
                        ),
                        loading: () => GreetingSection(
                          username: username,
                          avatarUrl: avatarUrl,
                          points: 0,
                        ),
                        error: (error, stack) => GreetingSection(
                          username: username,
                          avatarUrl: avatarUrl,
                          points: 0,
                        ),
                      );
                    },
                    loading: () => const GreetingSection(
                      username: "Đang tải...",
                      isLoading: true,
                    ),
                    error: (error, stack) =>
                        const GreetingSection(username: "Người dùng"),
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SearchBarWidget(),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: ActionCard(),
                ),
                const SizedBox(height: 16),
                // Category Section với dữ liệu từ API
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: categoriesAsync.when(
                    data: (categories) =>
                        CategorySection(categories: categories),
                    loading: () => const CategorySection(isLoading: true),
                    error: (error, stack) =>
                        CategorySection(errorMessage: error.toString()),
                  ),
                ),
                const SizedBox(height: 16),
                // Recent Section với lịch sử làm bài từ API
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: recentHistoryAsync.when(
                    data: (history) => RecentSection(examHistory: history),
                    loading: () => const RecentSection(isLoading: true),
                    error: (error, stack) =>
                        RecentSection(errorMessage: error.toString()),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function để lấy tên chính (tên cuối) từ họ tên đầy đủ
  String _getFirstName(String fullName) {
    // Loại bỏ khoảng trắng thừa và các ký tự đặc biệt trong ngoặc
    String cleaned = fullName.trim();

    // Loại bỏ phần trong ngoặc (SV), (GV), v.v.
    cleaned = cleaned.replaceAll(RegExp(r'\s*\([^)]*\)\s*'), '').trim();

    // Tách các từ
    List<String> parts = cleaned.split(RegExp(r'\s+'));

    // Lấy tên cuối (tên chính) - phần tử cuối cùng
    if (parts.isNotEmpty) {
      return parts.last;
    }

    return fullName;
  }
}

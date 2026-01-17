import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/teacher_stats_model.dart';
import 'package:frontend/providers/service_providers.dart';
import 'package:frontend/providers/user_provider.dart';

final teacherStatsProvider = FutureProvider.autoDispose<TeacherStatsModel>((
  ref,
) async {
  final teacherService = ref.watch(teacherServiceProvider);
  return await teacherService.getTeacherStats();
});

class TeacherDashboardPage extends ConsumerWidget {
  const TeacherDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = ref.watch(userProvider).value;
    final statsAsync = ref.watch(teacherStatsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(teacherStatsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with greeting
                  _buildGreetingSection(user?.fullName ?? 'Giáo viên'),
                  const SizedBox(height: 24),

                  // Stats cards
                  statsAsync.when(
                    data: (stats) => Column(
                      children: [
                        _buildStatsGrid(stats, colorScheme, context),
                        const SizedBox(height: 24),
                        _buildDetailedStats(stats, colorScheme, context),
                      ],
                    ),
                    loading: () => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              color: colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Đang tải thống kê...',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    error: (error, stack) => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: colorScheme.error,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Lỗi tải thống kê: ${error.toString()}',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection(String fullName) {
    final firstName = fullName.split(' ').last.isEmpty
        ? 'Giáo viên'
        : fullName.split(' ').last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Xin chào, $firstName! 👋',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Đây là bảng điều khiển của bạn',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(
    TeacherStatsModel stats,
    ColorScheme colorScheme,
    BuildContext context,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(
          title: 'Bài Thi',
          value: stats.totalExams.toString(),
          icon: Icons.quiz,
          color: Colors.blue,
          colorScheme: colorScheme,
        ),
        _StatCard(
          title: 'Câu Hỏi',
          value: stats.totalQuestions.toString(),
          icon: Icons.help_outline,
          color: Colors.purple,
          colorScheme: colorScheme,
        ),
        _StatCard(
          title: 'Sinh Viên',
          value: stats.totalStudents.toString(),
          icon: Icons.people,
          color: Colors.green,
          colorScheme: colorScheme,
        ),
        _StatCard(
          title: 'Lần Làm Bài',
          value: stats.totalExamAttempts.toString(),
          icon: Icons.assignment,
          color: Colors.orange,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildDetailedStats(
    TeacherStatsModel stats,
    ColorScheme colorScheme,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thống Kê Chi Tiết',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              _DetailedStatRow(
                label: 'Mã Giáo Viên',
                value: stats.teacherCode ?? 'N/A',
                icon: Icons.badge,
              ),
              Divider(color: colorScheme.outlineVariant),
              _DetailedStatRow(
                label: 'Tên Giáo Viên',
                value: stats.fullName ?? 'N/A',
                icon: Icons.person,
              ),
              Divider(color: colorScheme.outlineVariant),
              _DetailedStatRow(
                label: 'Điểm Trung Bình',
                value: '${stats.averageScore.toStringAsFixed(2)}/100',
                icon: Icons.star,
                valueColor: Colors.amber,
              ),
              Divider(color: colorScheme.outlineVariant),
              _DetailedStatRow(
                label: 'Phản Hồi Nhận Được',
                value: stats.totalFeedbacks.toString(),
                icon: Icons.feedback,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final ColorScheme colorScheme;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailedStatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _DetailedStatRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontSize: 14)),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/models/exam_category_model.dart';
import 'package:frontend/screens/exam/exam_list_screen.dart';

class CategorySection extends StatelessWidget {
  final List<ExamCategoryModel>? categories;
  final bool isLoading;
  final String? errorMessage;

  const CategorySection({
    super.key,
    this.categories,
    this.isLoading = false,
    this.errorMessage,
  });

  // Màu sắc cho từng category (dựa trên index)
  static const List<Map<String, Color>> categoryColors = [
    {'color': Color(0xFFBADFDB), 'textColor': Color(0xFF016B61)},
    {'color': Color(0xFFB0DB9C), 'textColor': Color(0xFF3A6F43)},
    {'color': Color(0xFFF5D2D2), 'textColor': Color(0xFFC75B7A)},
    {'color': Color(0xFFE8D5B7), 'textColor': Color(0xFF8B6914)},
    {'color': Color(0xFFD5E8F7), 'textColor': Color(0xFF2E5A8B)},
    {'color': Color(0xFFE8D5F7), 'textColor': Color(0xFF6B2E8B)},
  ];

  // Icon cho từng category (dựa trên index hoặc tên)
  IconData _getIconForCategory(String name, int index) {
    final lowerName = name.toLowerCase();
    // Programming & IT related
    if (lowerName.contains('java') || lowerName.contains('lập trình')) {
      return Icons.code_rounded;
    } else if (lowerName.contains('cơ sở dữ liệu') ||
        lowerName.contains('database') ||
        lowerName.contains('sql')) {
      return Icons.storage_rounded;
    } else if (lowerName.contains('mạng') || lowerName.contains('network')) {
      return Icons.lan_rounded;
    } else if (lowerName.contains('web') || lowerName.contains('html')) {
      return Icons.web_rounded;
    } else if (lowerName.contains('python')) {
      return Icons.terminal_rounded;
    } else if (lowerName.contains('mobile') ||
        lowerName.contains('android') ||
        lowerName.contains('ios')) {
      return Icons.phone_android_rounded;
    } else if (lowerName.contains('ai') ||
        lowerName.contains('machine learning')) {
      return Icons.psychology_rounded;
    } else if (lowerName.contains('security') ||
        lowerName.contains('bảo mật')) {
      return Icons.security_rounded;
    }
    // Education related
    else if (lowerName.contains('trường') || lowerName.contains('school')) {
      return Icons.school_rounded;
    } else if (lowerName.contains('kỹ năng') || lowerName.contains('skill')) {
      return Icons.self_improvement_rounded;
    } else if (lowerName.contains('đoàn') || lowerName.contains('hội')) {
      return Icons.groups_rounded;
    } else if (lowerName.contains('lịch sử') || lowerName.contains('history')) {
      return Icons.history_edu_rounded;
    } else if (lowerName.contains('khoa học') ||
        lowerName.contains('science')) {
      return Icons.science_rounded;
    } else if (lowerName.contains('toán') || lowerName.contains('math')) {
      return Icons.calculate_rounded;
    }
    // Mặc định dựa trên index
    final icons = [
      Icons.school_rounded,
      Icons.code_rounded,
      Icons.storage_rounded,
      Icons.menu_book_rounded,
      Icons.lightbulb_rounded,
      Icons.psychology_rounded,
    ];
    return icons[index % icons.length];
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị lỗi
    if (errorMessage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Chủ đề",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            height: 100,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                "Không thể tải danh mục: $errorMessage",
                style: TextStyle(color: Colors.red.shade700),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    // Hiển thị loading
    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Chủ đề",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    width: 130,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    // Không có dữ liệu
    if (categories == null || categories!.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Chủ đề",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            height: 100,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                "Chưa có chủ đề nào",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      );
    }

    // Hiển thị danh sách categories từ API
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Chủ đề",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: Builder(
            builder: (context) {
              // Lọc chỉ các category có bài thi
              final categoriesWithExams = categories!
                  .where((category) => category.totalExams > 0)
                  .toList();

              // Nếu không có category nào có bài thi
              if (categoriesWithExams.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      "Chưa có chủ đề nào có bài thi",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categoriesWithExams.length,
                itemBuilder: (context, index) {
                  final category = categoriesWithExams[index];
                  final colorSet =
                      categoryColors[index % categoryColors.length];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ExamListScreen(categoryId: category.id),
                          ),
                        );
                      },
                      child: _buildCategoryCard(
                        category.name,
                        _getIconForCategory(category.name, index),
                        colorSet['color']!,
                        colorSet['textColor']!,
                        category.totalExams,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    String label,
    IconData icon,
    Color color,
    Color textColor,
    int totalExams,
  ) {
    return Container(
      width: 130,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Icon(icon, size: 36, color: textColor),
        ],
      ),
    );
  }
}

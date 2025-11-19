import 'package:flutter/material.dart';
import 'package:frontend/screens/exam/exam_list_screen.dart';
import 'category_item.dart';

class CategoryList extends StatelessWidget {
  final String searchQuery;

  const CategoryList({super.key, required this.searchQuery});

  // Sample data - replace with API call later
  final List<Map<String, dynamic>> _categories = const [
    {
      'id': 1,
      'title': 'Kĩ năng mềm',
      'subtitle': 'Hôm nay',
      'image': 'https://via.placeholder.com/100',
      'examCount': 5,
    },
    {
      'id': 2,
      'title': 'Nhà trường',
      'subtitle': 'Hôm nay',
      'image': 'https://via.placeholder.com/100',
      'examCount': 3,
    },
    {
      'id': 3,
      'title': 'Tiền học phí và bảo hiểm thân t...',
      'subtitle': '3 ngày trước',
      'image': 'https://via.placeholder.com/100',
      'examCount': 2,
    },
    {
      'id': 4,
      'title': 'Lệ phí',
      'subtitle': 'Hôm nay',
      'image': 'https://via.placeholder.com/100',
      'examCount': 4,
    },
    {
      'id': 5,
      'title': 'Đoàn hội',
      'subtitle': 'Hôm nay',
      'image': 'https://via.placeholder.com/100',
      'examCount': 6,
    },
    {
      'id': 6,
      'title': 'Kĩ năng sống',
      'subtitle': 'Hôm nay',
      'image': 'https://via.placeholder.com/100',
      'examCount': 8,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter categories based on search query
    final filteredCategories = _categories
        .where(
          (category) =>
              category['title'].toString().toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              category['subtitle'].toString().toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
        )
        .toList();

    if (filteredCategories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'Không tìm thấy chủ đề',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredCategories.length,
        itemBuilder: (context, index) {
          final category = filteredCategories[index];
          return Column(
            children: [
              CategoryItem(
                title: category['title'],
                subtitle: category['subtitle'],
                image: category['image'],
                examCount: category['examCount'],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExamListScreen(),
                    ),
                  );
                },
              ),
              if (index < filteredCategories.length - 1)
                Divider(color: Colors.grey.shade200, height: 16),
            ],
          );
        },
      ),
    );
  }
}

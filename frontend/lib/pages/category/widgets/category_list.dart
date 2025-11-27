import 'package:flutter/material.dart';
import 'package:frontend/models/exam_category_model.dart';
import 'package:frontend/screens/exam/exam_list_screen.dart';
import 'category_item.dart';

class CategoryList extends StatelessWidget {
  final List<ExamCategoryModel> categories;

  const CategoryList({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(child: Text("Không tìm thấy chủ đề"));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final item = categories[index];
          return Column(
            children: [
              CategoryItem(
                title: item.name,
                subtitle: "Có ${item.totalExams} kỳ thi",
                image: "",
                examCount: item.totalExams,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExamListScreen(categoryId: item.id),
                    ),
                  );
                },
              ),
              if (index < categories.length - 1)
                Divider(height: 16, color: Colors.grey.shade200),
            ],
          );
        },
      ),
    );
  }
}

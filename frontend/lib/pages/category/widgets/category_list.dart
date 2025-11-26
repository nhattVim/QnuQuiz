import 'package:flutter/material.dart';
import 'package:frontend/models/exam_category_model.dart';
import 'package:frontend/screens/exam/exam_list_screen.dart';
import 'package:frontend/services/exam_service.dart';
import 'category_item.dart';

class CategoryList extends StatefulWidget {
  final String searchQuery;

  const CategoryList({super.key, required this.searchQuery});

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  List<ExamCategoryModel> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      categories = await ExamService().getAllCategories();
    } catch (_) {}
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = categories.where((c) {
      final q = widget.searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(q);
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text("Không tìm thấy chủ đề"),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final item = filtered[index];
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
                      builder: (_) => ExamListScreen(
                        categoryId: item.id,
                      ),
                    ),
                  );
                },
              ),
              if (index < filtered.length - 1)
                Divider(height: 16, color: Colors.grey.shade200),
            ],
          );
        },
      ),
    );
  }
}

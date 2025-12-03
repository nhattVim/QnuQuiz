import 'package:flutter/material.dart';
import 'package:frontend/models/exam_category_model.dart';
import 'package:frontend/services/exam_service.dart';
import 'widgets/category_header.dart';
import 'widgets/category_list.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String searchQuery = '';
  String sortOrder = 'desc';
  List<ExamCategoryModel> allCategories = [];
  List<ExamCategoryModel> filteredCategories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ExamService().getAllCategories();
      setState(() {
        allCategories = categories;
        _applyFiltersAndSort();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _applyFiltersAndSort() {
    // Filter by search query
    List<ExamCategoryModel> filtered = allCategories.where((c) {
      final q = searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(q);
    }).toList();

    // Sort by creation time
    filtered.sort((a, b) {
      if (sortOrder == 'desc') {
        return b.id.compareTo(a.id); // Mới nhất (id lớn hơn)
      } else {
        return a.id.compareTo(b.id); // Cũ nhất (id nhỏ hơn)
      }
    });

    setState(() {
      filteredCategories = filtered;
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
    });
    _applyFiltersAndSort();
  }

  void _onSortChanged(String newSortOrder) {
    setState(() {
      sortOrder = newSortOrder;
    });
    _applyFiltersAndSort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                'Chủ đề',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Header with search and sort (fixed, not scrolling)
            CategoryHeader(
              totalCategories: filteredCategories.length,
              onSearchChanged: _onSearchChanged,
              onSortChanged: _onSortChanged,
            ),

            const SizedBox(height: 8),

            // Category list (scrollable)
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: CategoryList(categories: filteredCategories),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

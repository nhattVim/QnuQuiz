import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exam_category_model.dart';
import 'package:frontend/providers/service_providers.dart';
import 'package:frontend/utils/vietnamese_helper.dart';

import 'widgets/category_header.dart';
import 'widgets/category_list.dart';

class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({super.key});

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage> {
  String searchQuery = '';
  String sortOrder = 'desc';
  List<ExamCategoryModel> allCategories = [];
  List<ExamCategoryModel> filteredCategories = [];
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                'Chủ đề',
                style: TextStyle(
                  color: colorScheme.onSurface,
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

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _applyFiltersAndSort() {
    // Filter by search query (Vietnamese tone insensitive)
    List<ExamCategoryModel> filtered = allCategories.where((c) {
      return VietnameseHelper.containsIgnoreTones(c.name, searchQuery);
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

  Future<void> _loadCategories() async {
    try {
      final categories = await ref.read(examServiceProvider).getAllCategories();
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
}

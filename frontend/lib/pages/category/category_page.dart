import 'package:flutter/material.dart';
import 'widgets/category_header.dart';
import 'widgets/category_list.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String searchQuery = '';

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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Header with search and sort (fixed, not scrolling)
            CategoryHeader(
              onSearchChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),

            const SizedBox(height: 8),

            // Category list (scrollable)
            Expanded(
              child: SingleChildScrollView(
                child: CategoryList(searchQuery: searchQuery),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

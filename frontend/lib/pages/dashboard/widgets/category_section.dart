import 'package:flutter/material.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'label': 'Nhà trường', 'icon': Icons.school_rounded, 'color': Colors.teal.shade100},
      {'label': 'Đoàn hội', 'icon': Icons.groups_rounded, 'color': Colors.pink.shade100},
      {'label': 'Kỹ năng sống', 'icon': Icons.self_improvement_rounded, 'color': Colors.green.shade100},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Danh mục",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: categories
              .map((item) => _buildCategoryCard(
                    item['label'] as String,
                    item['icon'] as IconData,
                    item['color'] as Color,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.black54),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'label': 'Nhà trường',
        'icon': Icons.school_rounded,
        'color': const Color(0xFFBADFDB),
        'textColor': const Color(0xFF016B61),
      },
      {
        'label': 'Kỹ năng sống',
        'icon': Icons.self_improvement_rounded,
        'color': const Color(0xFFB0DB9C),
        'textColor': const Color(0xFF3A6F43),
      },
      {
        'label': 'Đoàn hội',
        'icon': Icons.groups_rounded,
        'color': const Color(0xFFF5D2D2),
        'textColor': const Color(0xFFC75B7A),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Danh mục",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final item = categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildCategoryCard(
                  item['label'] as String,
                  item['icon'] as IconData,
                  item['color'] as Color,
                  item['textColor'] as Color,
                ),
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
          ),
          const SizedBox(height: 4),
          Icon(icon, size: 48, color: textColor),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class RecentSection extends StatelessWidget {
  const RecentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'title': 'Kĩ năng mềm cơ bản', 'progress': '6/12', 'status': 'Tiếp tục'},
      {'title': 'Kí túc xá và trọ', 'progress': '12/12', 'status': 'Xem lại'},
      {'title': 'Học phí và trợ cấp', 'progress': '6/12', 'status': 'Tiếp tục'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Làm gần đây",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Column(children: items.map((e) => _buildRecentItem(e)).toList()),
      ],
    );
  }

  Widget _buildRecentItem(Map<String, String> data) {
    final isCompleted = data['status'] == 'Xem lại';
    final color = isCompleted ? Colors.blue : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book_rounded, color: Colors.amber, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title']!,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  data['progress']!,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              // withOpacity is deprecated; use withAlpha to avoid precision-loss deprecation
              color: color.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              data['status']!,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

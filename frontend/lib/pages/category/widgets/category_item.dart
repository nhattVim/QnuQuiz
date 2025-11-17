import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final int examCount;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.examCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade200,
                image: DecorationImage(
                  image: NetworkImage(image),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {},
                ),
              ),
              child: image.isEmpty
                  ? Center(
                      child: Icon(Icons.image, color: Colors.grey.shade400),
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Subtitle
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),

                  const SizedBox(height: 8),

                  // Exam count row
                  Row(
                    children: [
                      Icon(Icons.book_outlined, size: 16, color: Colors.blue),
                      const SizedBox(width: 6),
                      Text(
                        '$examCount kỳ thi',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

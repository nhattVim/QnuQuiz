import 'package:flutter/material.dart';

class QuizQuestion extends StatelessWidget {
  final String questionText;
  final String? imageUrl;

  const QuizQuestion({super.key, required this.questionText, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Text
        Text(
          questionText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 16),

        // Question Image (placeholder)
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: imageUrl != null
                ? Image.asset(
                    imageUrl!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: Colors.grey,
                      );
                    },
                  )
                : const Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: Colors.grey,
                  ),
          ),
        ),
      ],
    );
  }
}

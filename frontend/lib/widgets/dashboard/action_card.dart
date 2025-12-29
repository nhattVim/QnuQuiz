import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/screens/exam/exam_list_screen.dart';

class ActionCard extends StatelessWidget {
  const ActionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // give a fixed height so Stack/Positioned.fill have finite constraints
      padding: const EdgeInsets.only(right: 16),
      height: 140,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // SVG background, painted first (so it's behind the content)
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: SvgPicture.asset(
                'assets/images/circle-scatter-haikei.svg',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Foreground content that will be painted over the SVG
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Trả lời và ghi điểm",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Bắt đầu với những câu hỏi thường gặp",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const ExamListScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Xem ngay",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

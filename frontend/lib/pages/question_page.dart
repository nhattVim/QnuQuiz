import 'package:flutter/material.dart';
import 'package:frontend/widgets/link_text.dart';

class QuestionPage extends StatelessWidget {
  const QuestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: SafeArea(
        child: Center(
          child: Column(
            children: [
              const Text(
                "Tạo bộ câu hỏi",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("Nhập bộ câu hỏi"),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("Xuất bộ câu hỏi"),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  const Text(
                    "Danh sách bộ câu hỏi",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
                  ),
                  const Spacer(),
                  LinkText(text: "Mới nhất", onPressed: () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

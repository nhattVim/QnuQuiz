import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': 'Làm thế nào để đăng ký?',
        'a': 'Vào màn hình đăng nhập và chọn "Đăng ký".',
      },
      {
        'q': 'Quên mật khẩu?',
        'a': 'Nhấn "Quên mật khẩu" và làm theo hướng dẫn.',
      },
      {'q': 'Ứng dụng có miễn phí không?', 'a': 'Hoàn toàn miễn phí!'},
      {
        'q': 'Làm sao để liên hệ hỗ trợ?',
        'a': 'Gửi email đến support@example.com',
      },
    ];

    return SizedBox.expand(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.help_outline, size: 60, color: Colors.blue),
                  SizedBox(height: 12),
                  Text(
                    'Câu hỏi thường gặp',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  final faq = faqs[index];
                  return ExpansionTile(
                    title: Text(
                      faq['q']!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(faq['a']!),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

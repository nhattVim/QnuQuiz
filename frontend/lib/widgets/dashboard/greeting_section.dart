import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';

class GreetingSection extends StatelessWidget {
  final String username;
  const GreetingSection({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: Colors.brown,
          child: Icon(Icons.person, color: Colors.white),
        ),

        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Xin chào, $username 👋",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Text(
              "Hãy bắt đầu câu đố nào!",
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Boxicons.bx_bolt_circle, color: Colors.amber, size: 20),
                  SizedBox(width: 4),
                  Text(
                    "1000",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade100,
              child: IconButton(
                icon: const Icon(Boxicons.bx_bell, size: 20),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';

class GreetingSection extends StatelessWidget {
  final String username;
  final String? avatarUrl;
  final int points;
  final bool isLoading;

  const GreetingSection({
    super.key,
    required this.username,
    this.avatarUrl,
    this.points = 0,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar với hỗ trợ URL từ API
        isLoading
            ? const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            : _buildAvatar(),

        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isLoading
                  ? Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )
                  : Text(
                      "Xin chào, $username 👋",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              const SizedBox(height: 4),
              const Text(
                "Hãy bắt đầu câu đố nào!",
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Boxicons.bx_bolt_circle,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    points.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
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

  Widget _buildAvatar() {
    // Nếu không có avatar URL, hiển thị icon mặc định
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return const CircleAvatar(
        radius: 20,
        backgroundColor: Colors.brown,
        child: Icon(Icons.person, color: Colors.white),
      );
    }

    // Nếu có avatar URL, sử dụng Image.network với error handling
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.brown,
      child: ClipOval(
        child: Image.network(
          avatarUrl!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // Khi load ảnh lỗi, hiển thị icon mặc định
            return const Icon(Icons.person, color: Colors.white, size: 24);
          },
        ),
      ),
    );
  }
}

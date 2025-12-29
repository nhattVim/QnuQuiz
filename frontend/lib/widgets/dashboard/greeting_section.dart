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
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        // Avatar với hỗ trợ URL từ API
        isLoading
            ? CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.surfaceContainerHighest,
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : _buildAvatar(colorScheme),

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
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )
                  : Text(
                      "Xin chào, $username 👋",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              const SizedBox(height: 4),
              Text(
                "Hãy bắt đầu câu đố nào!",
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.54),
                  fontSize: 12,
                ),
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
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
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

  Widget _buildAvatar(ColorScheme colorScheme) {
    // Nếu không có avatar URL, hiển thị icon mặc định
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: colorScheme.primaryContainer,
        child: Icon(Icons.person, color: colorScheme.onPrimaryContainer),
      );
    }

    // Nếu có avatar URL, sử dụng Image.network với error handling
    return CircleAvatar(
      radius: 20,
      backgroundColor: colorScheme.primaryContainer,
      child: ClipOval(
        child: Image.network(
          avatarUrl!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // Khi load ảnh lỗi, hiển thị icon mặc định
            return Icon(
              Icons.person,
              color: colorScheme.onPrimaryContainer,
              size: 24,
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/screens/exam/exam_list_screen.dart';

class ActionCardData {
  final String title;
  final String subtitle;
  final String buttonText;
  final Color backgroundColor;
  final VoidCallback? onTap;

  ActionCardData({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.backgroundColor,
    this.onTap,
  });
}

class ActionCard extends StatefulWidget {
  const ActionCard({super.key});

  @override
  State<ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<ActionCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final List<ActionCardData> slides = [
      ActionCardData(
        title: "Trả lời và ghi điểm",
        subtitle: "Bắt đầu với những câu hỏi thường gặp",
        buttonText: "Xem ngay",
        backgroundColor: colorScheme.primary,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ExamListScreen()),
          );
        },
      ),
      ActionCardData(
        title: "Thách thức bản thân",
        subtitle: "Kiểm tra kiến thức với đề thi mới nhất",
        buttonText: "Làm bài",
        backgroundColor: colorScheme.tertiary,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ExamListScreen()),
          );
        },
      ),
      ActionCardData(
        title: "Ôn tập hiệu quả",
        subtitle: "Xem lại các bài đã làm và cải thiện điểm số",
        buttonText: "Xem lịch sử",
        backgroundColor: colorScheme.secondary,
        onTap: () {
          // Navigate to history or review screen
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ExamListScreen()),
          );
        },
      ),
    ];

    return SizedBox(
      height: 160,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: slides.length,
              itemBuilder: (context, index) {
                final slide = slides[index];
                return _buildSlide(context, slide, colorScheme);
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildPageIndicator(slides.length, colorScheme),
        ],
      ),
    );
  }

  Widget _buildSlide(
    BuildContext context,
    ActionCardData slide,
    ColorScheme colorScheme,
  ) {
    // Darken bright colors in dark mode for better text visibility
    final backgroundColor =
        colorScheme.brightness == Brightness.dark &&
            (slide.backgroundColor == colorScheme.tertiary ||
                slide.backgroundColor == colorScheme.secondary)
        ? Color.alphaBlend(
            Colors.black.withValues(alpha: 0.3),
            slide.backgroundColor,
          )
        : slide.backgroundColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // SVG background
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

          // Foreground content
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    slide.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    slide.subtitle,
                    style: TextStyle(
                      color: colorScheme.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: slide.onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        slide.buttonText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: backgroundColor,
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

  Widget _buildPageIndicator(int count, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';

class QuizHeader extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final String? timeRemaining;
  final VoidCallback onBackPressed;
  final Function(int) onQuestionSelected;
  final List<int?>? answeredQuestions; // Track câu đã trả lời

  const QuizHeader({
    super.key,
    required this.currentQuestion,
    this.totalQuestions = 50,
    this.timeRemaining = '5:30',
    required this.onBackPressed,
    required this.onQuestionSelected,
    this.answeredQuestions,
  });

  void _showQuestionSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn câu hỏi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: totalQuestions,
                itemBuilder: (context, index) {
                  final questionNumber = index + 1;
                  final isCurrentQuestion = questionNumber == currentQuestion;
                  final isAnswered =
                      answeredQuestions != null &&
                      answeredQuestions![index] != null;

                  Color bgColor = Colors.grey.shade200;
                  Color textColor = Colors.black;

                  if (isCurrentQuestion) {
                    bgColor = Colors.blue;
                    textColor = Colors.white;
                  } else if (!isAnswered) {
                    bgColor = Colors.amber.shade200;
                    textColor = Colors.black87;
                  }

                  return GestureDetector(
                    onTap: () {
                      onQuestionSelected(index);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: isCurrentQuestion
                            ? Border.all(color: Colors.blue, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$questionNumber',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Boxicons.bx_arrow_back, color: Colors.black),
        onPressed: onBackPressed,
      ),
      title: GestureDetector(
        onTap: () => _showQuestionSelector(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quiz $currentQuestion',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Boxicons.bx_chevron_down, size: 20, color: Colors.black),
          ],
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    timeRemaining ?? '5:30',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

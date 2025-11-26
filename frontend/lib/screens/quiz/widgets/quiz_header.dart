import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';

class QuizHeader extends StatefulWidget {
  final int currentQuestion;
  final int totalQuestions;
  final int? durationMinutes;
  final VoidCallback onBackPressed;
  final Function(int) onQuestionSelected;
  final List<int?>? answeredQuestions;

  const QuizHeader({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.durationMinutes,
    required this.onBackPressed,
    required this.onQuestionSelected,
    this.answeredQuestions,
  });

  @override
  State<QuizHeader> createState() => _QuizHeaderState();
}

class _QuizHeaderState extends State<QuizHeader> {
  late int remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    remainingSeconds = (widget.durationMinutes ?? 0) * 60;
    if (remainingSeconds > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            if (remainingSeconds > 0) {
              remainingSeconds--;
            } else {
              _timer?.cancel();
              // Optional: trigger auto-submit or notify user
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

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
                itemCount: widget.totalQuestions,
                itemBuilder: (context, index) {
                  final questionNumber = index + 1;
                  final isCurrentQuestion =
                      questionNumber == widget.currentQuestion;
                  final isAnswered =
                      widget.answeredQuestions != null &&
                      widget.answeredQuestions![index] != null;
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
                      widget.onQuestionSelected(index);
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
        onPressed: widget.onBackPressed,
      ),
      title: GestureDetector(
        onTap: () => _showQuestionSelector(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quiz ${widget.currentQuestion}',
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
        if (widget.durationMinutes != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      formattedTime,
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

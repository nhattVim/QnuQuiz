import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';

class QuizHeader extends StatefulWidget {
  final int currentQuestion;
  final int totalQuestions;
  final int? durationMinutes;
  final int remainingSeconds;
  final VoidCallback onBackPressed;
  final Function(int) onQuestionSelected;
  final List<int?>? answeredQuestions;

  const QuizHeader({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.durationMinutes,
    required this.remainingSeconds,
    required this.onBackPressed,
    required this.onQuestionSelected,
    this.answeredQuestions,
  });

  @override
  State<QuizHeader> createState() => _QuizHeaderState();
}

class _QuizHeaderState extends State<QuizHeader> {
  @override
  void dispose() {
    super.dispose();
  }

  String get formattedTime {
    final minutes = widget.remainingSeconds ~/ 60;
    final seconds = widget.remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showQuestionSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn câu hỏi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
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
                  Color bgColor = colorScheme.surfaceContainerHighest;
                  Color textColor = colorScheme.onSurface;
                  if (isCurrentQuestion) {
                    bgColor = colorScheme.primary;
                    textColor = colorScheme.onPrimary;
                  } else if (!isAnswered) {
                    bgColor = Colors.amber.withValues(alpha: 0.3);
                    textColor = colorScheme.onSurface;
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
                            ? Border.all(color: colorScheme.primary, width: 2)
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
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Boxicons.bx_arrow_back, color: colorScheme.onSurface),
        onPressed: widget.onBackPressed,
      ),
      title: GestureDetector(
        onTap: () => _showQuestionSelector(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quiz ${widget.currentQuestion}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Boxicons.bx_chevron_down,
              size: 20,
              color: colorScheme.onSurface,
            ),
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
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: colorScheme.onPrimary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formattedTime,
                      style: TextStyle(
                        color: colorScheme.onPrimary,
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

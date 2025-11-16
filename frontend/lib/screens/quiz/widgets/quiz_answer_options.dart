import 'package:flutter/material.dart';

class QuizAnswerOption extends StatelessWidget {
  final String answerText;
  final bool isSelected;
  final bool isCorrect;
  final bool showResult;
  final int answerIndex;
  final VoidCallback? onTap;

  const QuizAnswerOption({
    super.key,
    required this.answerText,
    required this.isSelected,
    required this.isCorrect,
    required this.showResult,
    required this.answerIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.grey.shade50;
    Color borderColor = Colors.grey.shade200;
    Color textColor = Colors.black;

    // Khi chọn (showResult = false) → blue highlight
    if (isSelected && !showResult) {
      bgColor = Colors.blue.shade50;
      borderColor = Colors.blue;
    }

    // Khi show result
    if (showResult) {
      if (isCorrect) {
        bgColor = Colors.green.shade50;
        borderColor = Colors.green;
      } else if (isSelected && !isCorrect) {
        bgColor = Colors.red.shade50;
        borderColor = Colors.red;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: !showResult ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(
              color: borderColor,
              width: isSelected && !showResult ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  answerText,
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ),
              if (showResult)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(
                    isCorrect
                        ? Icons.check_circle
                        : (isSelected ? Icons.cancel : null),
                    color: isCorrect ? Colors.green : Colors.red,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizAnswerOptions extends StatelessWidget {
  final List<String> answers;
  final int selectedAnswerIndex;
  final int correctAnswerIndex;
  final bool answered;
  final Function(int) onSelectAnswer;

  const QuizAnswerOptions({
    super.key,
    required this.answers,
    required this.selectedAnswerIndex,
    required this.correctAnswerIndex,
    required this.answered,
    required this.onSelectAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(answers.length, (index) {
        final isSelected = selectedAnswerIndex == index;
        final isCorrect = index == correctAnswerIndex;

        return QuizAnswerOption(
          answerText: answers[index],
          isSelected: isSelected,
          isCorrect: isCorrect,
          showResult: answered,
          answerIndex: index,
          onTap: () => onSelectAnswer(index),
        );
      }),
    );
  }
}

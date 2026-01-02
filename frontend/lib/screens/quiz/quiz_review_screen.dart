import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:frontend/models/exam_review_model.dart';
import 'package:frontend/models/exam_answer_review_model.dart';
import 'package:frontend/screens/feedback_screen.dart';

class QuizReviewScreen extends StatelessWidget {
  final ExamReviewModel? examReview;
  final List<Map<String, dynamic>>? quizData;
  final List<int?>? answeredQuestions;
  final int? totalQuestions; // Tổng số câu hỏi trong bài thi
  final int? examId;

  const QuizReviewScreen({
    super.key,
    this.examReview,
    this.quizData,
    this.answeredQuestions,
    this.totalQuestions,
    this.examId,
  });

  @override
  Widget build(BuildContext context) {
    // Nếu có examReview từ API, sử dụng nó
    if (examReview != null) {
      return _buildFromApiReview(context);
    }
    // Nếu không, sử dụng dữ liệu local (backward compatible)
    else if (quizData != null && answeredQuestions != null) {
      return _buildFromLocalData(context);
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Xem lại đáp án', style: TextStyle(fontSize: 20)),
        ),
        body: const Center(child: Text('Không có dữ liệu')),
      );
    }
  }

  // Build UI từ API Review Data
  Widget _buildFromApiReview(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    int correctCount = 0;
    for (var answer in examReview!.answers) {
      final ans = answer as ExamAnswerReviewModel;
      if (ans.isCorrect) {
        correctCount++;
      }
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Boxicons.bx_arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Xem lại đáp án',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    examReview!.examTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Tổng câu',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${totalQuestions ?? examReview!.answers.length}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Câu đúng',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$correctCount',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Câu sai',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(totalQuestions ?? examReview!.answers.length) - correctCount}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(
                        alpha: Theme.of(context).brightness == Brightness.dark
                            ? 0.15
                            : 0.2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Boxicons.bx_bolt_circle,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.amber.shade300
                              : Colors.amber,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${examReview!.score} điểm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Questions review từ API
            ...List.generate(examReview!.answers.length, (index) {
              final answer =
                  examReview!.answers[index] as ExamAnswerReviewModel;
              final isCorrect = answer.isCorrect;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question header
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCorrect
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCorrect ? 'Đúng' : 'Sai',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isCorrect
                                    ? (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.green.shade300
                                          : Colors.green)
                                    : (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.red.shade300
                                          : Colors.red),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              answer.type == 'MULTIPLE_CHOICE'
                                  ? 'Trắc nghiệm'
                                  : 'Đúng/Sai',
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Rating icon on the right
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FeedbackScreen(
                                examId: examId,
                                examTitle: examReview!.examTitle,
                                questionId: answer.questionId,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.amber.withValues(
                              alpha:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? 0.15
                                  : 0.2,
                            ),
                          ),
                          child: Icon(
                            Icons.star_border,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.amber.shade300
                                : Colors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Question text
                  Text(
                    answer.questionText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Options
                  Column(
                    children: List.generate(answer.options.length, (optIndex) {
                      // Sort options by position before displaying
                      final sortedOptions = [...answer.options]
                        ..sort(
                          (a, b) =>
                              (a.position ?? 0).compareTo((b.position ?? 0)),
                        );
                      final option = sortedOptions[optIndex];
                      final isCorrectOption = option.correct;
                      final isStudentAnswer =
                          answer.selectedOptionId == option.id;

                      Color backgroundColor = colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5);
                      Color borderColor = colorScheme.outline.withValues(
                        alpha: 0.5,
                      );
                      Color textColor = colorScheme.onSurface;
                      IconData? icon;
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;

                      if (isCorrectOption) {
                        backgroundColor = isDark
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.green.shade100;
                        borderColor = isDark
                            ? Colors.green.shade700
                            : Colors.green;
                        textColor = isDark
                            ? Colors.green.shade300
                            : Colors.green.shade800;
                        icon = Icons.check_circle;
                      } else if (isStudentAnswer && !isCorrect) {
                        backgroundColor = isDark
                            ? Colors.red.withValues(alpha: 0.2)
                            : Colors.red.shade100;
                        borderColor = isDark ? Colors.red.shade700 : Colors.red;
                        textColor = isDark
                            ? Colors.red.shade300
                            : Colors.red.shade800;
                        icon = Icons.cancel;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            border: Border.all(color: borderColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              if (icon != null)
                                Icon(
                                  icon,
                                  color: isCorrectOption
                                      ? Colors.green
                                      : Colors.red,
                                  size: 20,
                                )
                              else
                                Icon(
                                  Icons.circle_outlined,
                                  color: colorScheme.outline,
                                  size: 20,
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option.content,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),

                  // Divider
                  if (index < examReview!.answers.length - 1)
                    Divider(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                      thickness: 1,
                      height: 32,
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // Build UI từ Local Data (backward compatible)
  Widget _buildFromLocalData(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    int correctCount = 0;
    for (int i = 0; i < quizData!.length; i++) {
      if (answeredQuestions![i] == quizData![i]['correctAnswerIndex']) {
        correctCount++;
      }
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Boxicons.bx_arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Xem lại đáp án',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        'Tổng câu',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${quizData!.length}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Câu đúng',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$correctCount',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Câu sai',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${quizData!.length - correctCount}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Questions review
            ...List.generate(quizData!.length, (index) {
              final question = quizData![index];
              final userAnswer = answeredQuestions![index];
              final correctAnswerIndex = question['correctAnswerIndex'];
              final isCorrect = userAnswer == correctAnswerIndex;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question header
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCorrect
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCorrect ? 'Đúng' : 'Sai',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isCorrect
                                    ? (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.green.shade300
                                          : Colors.green)
                                    : (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.red.shade300
                                          : Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Question text
                  Text(
                    question['question'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Answers
                  Column(
                    children: List.generate(
                      (question['answers'] as List).length,
                      (answerIndex) {
                        final answer = question['answers'][answerIndex];
                        final isUserAnswer = userAnswer == answerIndex;
                        final isCorrectAnswer =
                            correctAnswerIndex == answerIndex;

                        Color backgroundColor = colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.5);
                        Color borderColor = colorScheme.outline.withValues(
                          alpha: 0.5,
                        );
                        Color textColor = colorScheme.onSurface;
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;

                        if (isCorrectAnswer) {
                          backgroundColor = isDark
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.green.shade100;
                          borderColor = isDark
                              ? Colors.green.shade700
                              : Colors.green;
                          textColor = isDark
                              ? Colors.green.shade300
                              : Colors.green.shade800;
                        } else if (isUserAnswer && !isCorrect) {
                          backgroundColor = isDark
                              ? Colors.red.withValues(alpha: 0.2)
                              : Colors.red.shade100;
                          borderColor = isDark
                              ? Colors.red.shade700
                              : Colors.red;
                          textColor = isDark
                              ? Colors.red.shade300
                              : Colors.red.shade800;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              border: Border.all(color: borderColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                if (isCorrectAnswer)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 20,
                                  )
                                else if (isUserAnswer && !isCorrect)
                                  const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                    size: 20,
                                  )
                                else
                                  Icon(
                                    Icons.circle_outlined,
                                    color: colorScheme.outline,
                                    size: 20,
                                  ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    answer,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Divider
                  if (index < quizData!.length - 1)
                    Divider(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                      thickness: 1,
                      height: 32,
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';

class QuizReviewScreen extends StatelessWidget {
  final List<Map<String, dynamic>> quizData;
  final List<int?> answeredQuestions;

  const QuizReviewScreen({
    super.key,
    required this.quizData,
    required this.answeredQuestions,
  });

  @override
  Widget build(BuildContext context) {
    int correctCount = 0;
    for (int i = 0; i < quizData.length; i++) {
      if (answeredQuestions[i] == quizData[i]['correctAnswerIndex']) {
        correctCount++;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Boxicons.bx_arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Xem lại đáp án',
          style: TextStyle(
            color: Colors.black,
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
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Tổng câu',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${quizData.length}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Câu đúng',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
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
                      const Text(
                        'Câu sai',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${quizData.length - correctCount}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Questions review
            ...List.generate(quizData.length, (index) {
              final question = quizData[index];
              final userAnswer = answeredQuestions[index];
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
                                color: isCorrect ? Colors.green : Colors.red,
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
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

                        Color backgroundColor = Colors.grey.shade100;
                        Color borderColor = Colors.grey.shade300;
                        Color textColor = Colors.black;

                        if (isCorrectAnswer) {
                          backgroundColor = Colors.green.shade100;
                          borderColor = Colors.green;
                          textColor = Colors.green.shade800;
                        } else if (isUserAnswer && !isCorrect) {
                          backgroundColor = Colors.red.shade100;
                          borderColor = Colors.red;
                          textColor = Colors.red.shade800;
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
                                    color: Colors.grey.shade400,
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
                  if (index < quizData.length - 1)
                    Divider(
                      color: Colors.grey.shade300,
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

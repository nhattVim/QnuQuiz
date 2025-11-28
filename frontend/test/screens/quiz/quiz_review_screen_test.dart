import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/exam_answer_review_model.dart';
import 'package:frontend/models/question_option_model.dart';

void main() {
  group('S3.4 - Quiz Review Screen Tests', () {
    test('Sort question options by position', () {
      // Arrange
      final options = [
        QuestionOptionModel(
          id: 1,
          content: 'Option A',
          correct: false,
          position: 2,
        ),
        QuestionOptionModel(
          id: 2,
          content: 'Option B',
          correct: true,
          position: 0,
        ),
        QuestionOptionModel(
          id: 3,
          content: 'Option C',
          correct: false,
          position: 1,
        ),
      ];

      // Act
      final sortedOptions = List.from(options)
        ..sort((a, b) => a.position.compareTo(b.position));

      // Assert
      expect(sortedOptions[0].position, 0);
      expect(sortedOptions[1].position, 1);
      expect(sortedOptions[2].position, 2);
      expect(sortedOptions[0].content, 'Option B');
    });

    test('Find correct option in review', () {
      // Arrange
      final options = [
        QuestionOptionModel(
          id: 1,
          content: 'Option A',
          correct: false,
          position: 0,
        ),
        QuestionOptionModel(
          id: 2,
          content: 'Option B',
          correct: true,
          position: 1,
        ),
        QuestionOptionModel(
          id: 3,
          content: 'Option C',
          correct: false,
          position: 2,
        ),
      ];

      // Act
      final correctOptionIndex = options.indexWhere((o) => o.correct);

      // Assert
      expect(correctOptionIndex, 1);
      expect(options[correctOptionIndex].content, 'Option B');
    });

    test('Identify correct vs incorrect answers', () {
      // Arrange
      final answers = [
        ExamAnswerReviewModel(
          questionId: 1,
          questionText: 'Q1',
          selectedOptionId: 1,
          correctOptionId: 2,
          isCorrect: false,
          options: [],
        ),
        ExamAnswerReviewModel(
          questionId: 2,
          questionText: 'Q2',
          selectedOptionId: 2,
          correctOptionId: 2,
          isCorrect: true,
          options: [],
        ),
      ];

      // Act
      int correctCount = answers.where((a) => a.isCorrect).length;
      int incorrectCount = answers.where((a) => !a.isCorrect).length;

      // Assert
      expect(correctCount, 1);
      expect(incorrectCount, 1);
    });

    test('Calculate score from correct answers', () {
      // Arrange
      final answers = [
        ExamAnswerReviewModel(
          questionId: 1,
          questionText: 'Q1',
          selectedOptionId: 1,
          correctOptionId: 2,
          isCorrect: false,
          options: [],
        ),
        ExamAnswerReviewModel(
          questionId: 2,
          questionText: 'Q2',
          selectedOptionId: 2,
          correctOptionId: 2,
          isCorrect: true,
          options: [],
        ),
        ExamAnswerReviewModel(
          questionId: 3,
          questionText: 'Q3',
          selectedOptionId: 3,
          correctOptionId: 3,
          isCorrect: true,
          options: [],
        ),
      ];

      // Act
      int correctCount = answers.where((a) => a.isCorrect).length;
      int score = correctCount * 10; // each question worth 10 points

      // Assert
      expect(score, 20); // 2 correct * 10 = 20
    });

    test('Handle empty review data gracefully', () {
      // Arrange
      final answers = <ExamAnswerReviewModel>[];

      // Act
      int correctCount = answers.where((a) => a.isCorrect).length;

      // Assert
      expect(correctCount, 0);
    });

    test('Display correct vs selected answer for wrong answer', () {
      // Arrange
      final answer = ExamAnswerReviewModel(
        questionId: 1,
        questionText: 'What is 2+2?',
        selectedOptionId: 1, // selected 3
        correctOptionId: 2, // correct is 4
        isCorrect: false,
        options: [
          QuestionOptionModel(id: 1, content: '3', correct: false, position: 0),
          QuestionOptionModel(id: 2, content: '4', correct: true, position: 1),
        ],
      );

      // Act & Assert
      expect(answer.isCorrect, false);
      expect(answer.selectedOptionId, 1);
      expect(answer.correctOptionId, 2);
    });

    test('Check answer state for correct selection', () {
      // Arrange
      final answer = ExamAnswerReviewModel(
        questionId: 1,
        questionText: 'Which is correct?',
        selectedOptionId: 2,
        correctOptionId: 2,
        isCorrect: true,
        options: [],
      );

      // Act & Assert
      expect(answer.isCorrect, true);
      expect(answer.selectedOptionId, answer.correctOptionId);
    });
  });
}

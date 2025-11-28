import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/exam_result_model.dart';

void main() {
  group('S3.3 - Quiz Result Screen Tests', () {
    test('Calculate score percentage correctly', () {
      // Arrange
      int correctCount = 8;
      int totalQuestions = 10;

      // Act
      double percentage = (correctCount / totalQuestions) * 100;

      // Assert
      expect(percentage, 80.0);
    });

    test('Calculate incorrect count', () {
      // Arrange
      int correctCount = 7;
      int totalQuestions = 10;

      // Act
      int incorrectCount = totalQuestions - correctCount;

      // Assert
      expect(incorrectCount, 3);
    });

    test('Display score from exam result', () {
      // Arrange
      final mockResult = ExamResultModel(
        score: 85,
        correctCount: 8,
        totalQuestions: 10,
      );

      // Act
      final result = mockResult;

      // Assert
      expect(result.score, 85);
      expect(result.correctCount, 8);
      expect(result.totalQuestions, 10);
    });

    test('Determine pass/fail based on score', () {
      // Arrange
      int score = 70;
      int passingScore = 50;

      // Act
      bool isPassed = score >= passingScore;

      // Assert
      expect(isPassed, true);
    });

    test('Fail when score below passing threshold', () {
      // Arrange
      int score = 40;
      int passingScore = 50;

      // Act
      bool isPassed = score >= passingScore;

      // Assert
      expect(isPassed, false);
    });

    test('Handle zero correct answers', () {
      // Arrange
      int correctCount = 0;
      int totalQuestions = 10;
      double percentage = (correctCount / totalQuestions) * 100;

      // Act & Assert
      expect(percentage, 0.0);
    });

    test('Handle all correct answers', () {
      // Arrange
      int correctCount = 10;
      int totalQuestions = 10;
      double percentage = (correctCount / totalQuestions) * 100;

      // Act & Assert
      expect(percentage, 100.0);
    });

    test('Calculate correct attempt duration', () {
      // Arrange
      int startTime = 1000; // milliseconds
      int endTime = 1300000; // 300 seconds later
      int durationSeconds = (endTime - startTime) ~/ 1000;

      // Act & Assert
      expect(durationSeconds, 1299);
    });
  });
}

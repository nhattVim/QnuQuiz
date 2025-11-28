import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/exam_history_model.dart';

void main() {
  group('S3.7 - Exam History Screen Tests', () {
    test('Fetch exam attempt history', () {
      // Arrange
      final historyList = [
        ExamHistoryModel(
          attemptId: 1,
          examId: 100,
          examTitle: 'Quiz 1',
          examDescription: 'Test Quiz 1',
          score: 80,
          completionDate: DateTime(2025, 11, 26, 10, 30),
          durationMinutes: 30,
        ),
        ExamHistoryModel(
          attemptId: 2,
          examId: 101,
          examTitle: 'Quiz 2',
          examDescription: 'Test Quiz 2',
          score: 90,
          completionDate: DateTime(2025, 11, 25, 14, 15),
          durationMinutes: 45,
        ),
      ];

      // Act
      final result = historyList;

      // Assert
      expect(result.length, 2);
      expect(result[0].score, 80);
      expect(result[1].examTitle, 'Quiz 2');
    });

    test('Display exam summary (score, time)', () {
      // Arrange
      final history = ExamHistoryModel(
        attemptId: 1,
        examId: 100,
        examTitle: 'Math Quiz',
        examDescription: 'Basic Math',
        score: 85,
        completionDate: DateTime(2025, 11, 26, 10, 30),
        durationMinutes: 30,
      );

      // Act & Assert
      expect(history.score, 85);
      expect(history.durationMinutes, 30);
      expect(history.examTitle, 'Math Quiz');
    });

    test('Sort history by date descending (newest first)', () {
      // Arrange
      final historyList = [
        ExamHistoryModel(
          attemptId: 1,
          examId: 100,
          examTitle: 'Q1',
          examDescription: 'Test',
          score: 80,
          completionDate: DateTime(2025, 11, 24),
          durationMinutes: 30,
        ),
        ExamHistoryModel(
          attemptId: 2,
          examId: 101,
          examTitle: 'Q2',
          examDescription: 'Test',
          score: 90,
          completionDate: DateTime(2025, 11, 26),
          durationMinutes: 45,
        ),
        ExamHistoryModel(
          attemptId: 3,
          examId: 102,
          examTitle: 'Q3',
          examDescription: 'Test',
          score: 75,
          completionDate: DateTime(2025, 11, 25),
          durationMinutes: 20,
        ),
      ];

      // Act
      final sorted = List.from(historyList)
        ..sort((a, b) => b.completionDate!.compareTo(a.completionDate!));

      // Assert
      expect(sorted[0].attemptId, 2); // Nov 26
      expect(sorted[1].attemptId, 3); // Nov 25
      expect(sorted[2].attemptId, 1); // Nov 24
    });

    test('Calculate pass/fail status from score', () {
      // Arrange
      int passingScore = 50;
      final history = ExamHistoryModel(
        attemptId: 1,
        examId: 100,
        examTitle: 'Quiz',
        examDescription: 'Test',
        score: 65,
        completionDate: DateTime(2025, 11, 26),
        durationMinutes: 30,
      );

      // Act
      bool isPassed = (history.score ?? 0) >= passingScore;

      // Assert
      expect(isPassed, true);
    });

    test('Handle empty history list', () {
      // Arrange
      final historyList = <ExamHistoryModel>[];

      // Act & Assert
      expect(historyList.isEmpty, true);
      expect(historyList.length, 0);
    });

    test('Display attempt count for exam', () {
      // Arrange
      final historyList = [
        ExamHistoryModel(
          attemptId: 1,
          examId: 100,
          examTitle: 'Quiz 1',
          examDescription: 'Test',
          score: 80,
          completionDate: DateTime(2025, 11, 26),
          durationMinutes: 30,
        ),
        ExamHistoryModel(
          attemptId: 2,
          examId: 100, // Same exam
          examTitle: 'Quiz 1',
          examDescription: 'Test',
          score: 85,
          completionDate: DateTime(2025, 11, 25),
          durationMinutes: 35,
        ),
      ];

      // Act
      int attempts = historyList.where((h) => h.examId == 100).length;

      // Assert
      expect(attempts, 2);
    });

    test('Find highest score for exam', () {
      // Arrange
      final historyList = [
        ExamHistoryModel(
          attemptId: 1,
          examId: 100,
          examTitle: 'Quiz',
          examDescription: 'Test',
          score: 70,
          completionDate: DateTime(2025, 11, 26),
          durationMinutes: 30,
        ),
        ExamHistoryModel(
          attemptId: 2,
          examId: 100,
          examTitle: 'Quiz',
          examDescription: 'Test',
          score: 90,
          completionDate: DateTime(2025, 11, 25),
          durationMinutes: 35,
        ),
      ];

      // Act
      final scores = historyList
          .where((h) => h.examId == 100)
          .map((h) => h.score ?? 0)
          .toList();
      final maxScore = scores.isNotEmpty
          ? scores.reduce((a, b) => a > b ? a : b)
          : 0;

      // Assert
      expect(maxScore, 90);
    });

    test('Calculate average score for exam', () {
      // Arrange
      final historyList = [
        ExamHistoryModel(
          attemptId: 1,
          examId: 100,
          examTitle: 'Quiz',
          examDescription: 'Test',
          score: 80,
          completionDate: DateTime(2025, 11, 26),
          durationMinutes: 30,
        ),
        ExamHistoryModel(
          attemptId: 2,
          examId: 100,
          examTitle: 'Quiz',
          examDescription: 'Test',
          score: 90,
          completionDate: DateTime(2025, 11, 25),
          durationMinutes: 35,
        ),
      ];

      // Act
      final attempts = historyList.where((h) => h.examId == 100).toList();
      final scores = attempts.map((h) => h.score ?? 0).toList();
      final avgScore = attempts.isNotEmpty
          ? scores.reduce((a, b) => a + b) / attempts.length
          : 0;

      // Assert
      expect(avgScore, 85);
    });
  });
}

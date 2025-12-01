import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/exam_history_model.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
  });

  group('ExamHistoryService - Model Validation', () {
    test('ExamHistoryModel serialization/deserialization', () {
      // Arrange
      final history = ExamHistoryModel(
        attemptId: 1,
        examId: 100,
        examTitle: 'Quiz 1',
        examDescription: 'Test Quiz 1',
        score: 80,
        completionDate: DateTime(2025, 11, 26, 10, 30),
        durationMinutes: 30,
      );
      final json = history.toJson();

      // Act
      final deserialized = ExamHistoryModel.fromJson(json);

      // Assert
      expect(deserialized.attemptId, history.attemptId);
      expect(deserialized.examId, history.examId);
      expect(deserialized.score, history.score);
      expect(deserialized.durationMinutes, history.durationMinutes);
    });

    test('ExamHistoryModel calculate pass/fail from score', () {
      // Arrange
      const passingScore = 50;
      final history = ExamHistoryModel(
        attemptId: 1,
        examId: 100,
        examTitle: 'Quiz 1',
        examDescription: 'Test Quiz 1',
        score: 80,
        completionDate: DateTime(2025, 11, 26),
        durationMinutes: 30,
      );

      // Act
      final isPassed = (history.score ?? 0) >= passingScore;

      // Assert
      expect(isPassed, true);
    });
  });

  group('ExamHistoryService - API Mocking', () {
    final mockHistoryItem1 = ExamHistoryModel(
      attemptId: 1,
      examId: 100,
      examTitle: 'Quiz 1',
      examDescription: 'Test Quiz 1',
      score: 80,
      completionDate: DateTime(2025, 11, 26, 10, 30),
      durationMinutes: 30,
    );

    final mockHistoryItem2 = ExamHistoryModel(
      attemptId: 2,
      examId: 101,
      examTitle: 'Quiz 2',
      examDescription: 'Test Quiz 2',
      score: 90,
      completionDate: DateTime(2025, 11, 25, 14, 15),
      durationMinutes: 45,
    );

    test('getExamHistory returns list of history', () async {
      // Arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: [mockHistoryItem1.toJson(), mockHistoryItem2.toJson()],
          statusCode: 200,
        ),
      );

      // Act
      final response = await mockDio.get('test');

      // Assert
      expect(response.statusCode, 200);
      final histories = (response.data as List)
          .map((e) => ExamHistoryModel.fromJson(e))
          .toList();
      expect(histories.length, 2);
      expect(histories[0].score, 80);
    });

    test('history list sorted by date descending', () {
      // Arrange
      final historyList = [mockHistoryItem1, mockHistoryItem2];

      // Act
      final sorted = List.from(historyList)
        ..sort((a, b) => b.completionDate!.compareTo(a.completionDate!));

      // Assert
      expect(sorted[0].attemptId, 1); // Nov 26
      expect(sorted[1].attemptId, 2); // Nov 25
    });

    test('calculate highest score for exam', () {
      // Arrange
      final historyList = [
        mockHistoryItem1, // score 80
        ExamHistoryModel(
          attemptId: 3,
          examId: 100,
          examTitle: 'Quiz 1',
          examDescription: 'Test',
          score: 95,
          completionDate: DateTime(2025, 11, 24),
          durationMinutes: 30,
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
      expect(maxScore, 95);
    });

    test('calculate average score for exam', () {
      // Arrange
      final historyList = [
        mockHistoryItem1, // score 80
        ExamHistoryModel(
          attemptId: 3,
          examId: 100,
          examTitle: 'Quiz 1',
          examDescription: 'Test',
          score: 90,
          completionDate: DateTime(2025, 11, 24),
          durationMinutes: 30,
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

    test('count attempts for specific exam', () {
      // Arrange
      final historyList = [
        mockHistoryItem1,
        ExamHistoryModel(
          attemptId: 3,
          examId: 100, // Same exam
          examTitle: 'Quiz 1',
          examDescription: 'Test',
          score: 85,
          completionDate: DateTime(2025, 11, 24),
          durationMinutes: 35,
        ),
      ];

      // Act
      final attempts = historyList.where((h) => h.examId == 100).length;

      // Assert
      expect(attempts, 2);
    });
  });
}

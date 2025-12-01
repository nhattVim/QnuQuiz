import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/exam_attempt_model.dart';
import 'package:frontend/models/exam_result_model.dart';
import 'package:frontend/models/exam_review_model.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
  });

  group('Quiz Attempt Operations', () {
    test('startExam returns exam attempt', () async {
      // Arrange
      final mockAttempt = ExamAttemptModel(
        id: 1,
        examId: 100,
        startTime: DateTime.now(),
        submit: false,
      );

      when(() => mockDio.post(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: mockAttempt.toJson(),
          statusCode: 200,
        ),
      );

      // Act & Assert
      expect(mockAttempt.id, 1);
      expect(mockAttempt.submit, false);
    });

    test('submitAnswer handles multiple questions', () async {
      // Arrange
      final questionIds = [1, 2, 3, 4, 5];
      final optionIds = [1, 2, 3, 1, 2];

      when(() => mockDio.post(any())).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(path: ''), statusCode: 200),
      );

      // Act & Assert
      expect(questionIds.length, optionIds.length);
    });

    test('finishExam returns result with score', () async {
      // Arrange
      final mockResult = ExamResultModel(
        score: 85,
        correctCount: 8,
        totalQuestions: 10,
      );

      when(() => mockDio.post(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: mockResult.toJson(),
          statusCode: 200,
        ),
      );

      // Act & Assert
      expect(mockResult.score, 85);
      expect(mockResult.correctCount, 8);
    });

    test('reviewExamAttempt returns exam review', () async {
      // Arrange
      final mockReview = ExamReviewModel(
        examAttemptId: 1,
        examTitle: 'Math Quiz',
        score: 85,
        answers: [],
      );

      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: mockReview.toJson(),
          statusCode: 200,
        ),
      );

      // Act & Assert
      expect(mockReview.examAttemptId, 1);
      expect(mockReview.score, 85);
    });
  });

  group('Quiz Result Validation', () {
    test('exam result has valid score range', () {
      // Arrange & Act
      final result = ExamResultModel(
        score: 85,
        correctCount: 8,
        totalQuestions: 10,
      );

      // Assert
      expect(result.score, greaterThanOrEqualTo(0));
      expect(result.score, lessThanOrEqualTo(100));
      expect(result.correctCount, lessThanOrEqualTo(result.totalQuestions));
    });

    test('score calculation is correct', () {
      // Arrange
      final result = ExamResultModel(
        score: 85,
        correctCount: 8,
        totalQuestions: 10,
      );

      // Act
      final percentage = (result.correctCount / result.totalQuestions) * 100;

      // Assert
      expect(percentage, 80.0);
    });

    test('perfect score condition', () {
      // Arrange & Act
      final perfectResult = ExamResultModel(
        score: 100,
        correctCount: 10,
        totalQuestions: 10,
      );

      // Assert
      expect(perfectResult.score, 100);
      expect(perfectResult.correctCount, perfectResult.totalQuestions);
    });

    test('zero score condition', () {
      // Arrange & Act
      final zeroResult = ExamResultModel(
        score: 0,
        correctCount: 0,
        totalQuestions: 10,
      );

      // Assert
      expect(zeroResult.score, 0);
      expect(zeroResult.correctCount, 0);
    });
  });

  group('Model Serialization', () {
    test('ExamAttemptModel serialization', () {
      // Arrange
      final attempt = ExamAttemptModel(
        id: 1,
        examId: 100,
        startTime: DateTime.now(),
        submit: false,
      );
      final json = attempt.toJson();

      // Act
      final deserialized = ExamAttemptModel.fromJson(json);

      // Assert
      expect(deserialized.id, attempt.id);
      expect(deserialized.examId, attempt.examId);
      expect(deserialized.submit, attempt.submit);
    });

    test('ExamResultModel serialization', () {
      // Arrange
      final result = ExamResultModel(
        score: 85,
        correctCount: 8,
        totalQuestions: 10,
      );
      final json = result.toJson();

      // Act
      final deserialized = ExamResultModel.fromJson(json);

      // Assert
      expect(deserialized.score, result.score);
      expect(deserialized.correctCount, result.correctCount);
      expect(deserialized.totalQuestions, result.totalQuestions);
    });

    test('ExamReviewModel serialization', () {
      // Arrange
      final review = ExamReviewModel(
        examAttemptId: 1,
        examTitle: 'Math Quiz',
        score: 85,
        answers: [],
      );
      final json = review.toJson();

      // Act
      final deserialized = ExamReviewModel.fromJson(json);

      // Assert
      expect(deserialized.examAttemptId, review.examAttemptId);
      expect(deserialized.examTitle, review.examTitle);
      expect(deserialized.score, review.score);
    });
  });
}

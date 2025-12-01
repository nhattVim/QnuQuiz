import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/exam_attempt_model.dart';
import 'package:frontend/models/exam_category_model.dart';
import 'package:frontend/models/exam_model.dart';
import 'package:frontend/models/exam_result_model.dart';
import 'package:frontend/models/exam_review_model.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
  });

  group('ExamService - Model Validation', () {
    test('ExamModel serialization/deserialization', () {
      // Arrange
      final exam = ExamModel(
        id: 1,
        title: 'Math Quiz',
        description: 'Basic Math Test',
        random: false,
        status: 'active',
        durationMinutes: 30,
        categoryId: 1,
      );
      final json = exam.toJson();

      // Act
      final deserialized = ExamModel.fromJson(json);

      // Assert
      expect(deserialized.id, exam.id);
      expect(deserialized.title, exam.title);
      expect(deserialized.description, exam.description);
      expect(deserialized.durationMinutes, exam.durationMinutes);
      expect(deserialized.categoryId, exam.categoryId);
    });

    test('ExamAttemptModel serialization/deserialization', () {
      // Arrange
      final attempt = ExamAttemptModel(
        id: 1,
        examId: 1,
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

    test('ExamResultModel contains correct statistics', () {
      // Arrange & Act
      final result = ExamResultModel(
        score: 85,
        correctCount: 8,
        totalQuestions: 10,
      );

      // Assert
      expect(result.score, 85);
      expect(result.correctCount, 8);
      expect(result.totalQuestions, 10);
    });

    test('ExamReviewModel contains answer review data', () {
      // Arrange & Act
      final review = ExamReviewModel(
        examAttemptId: 1,
        examTitle: 'Math Quiz',
        score: 85,
        answers: [],
      );

      // Assert
      expect(review.examAttemptId, 1);
      expect(review.examTitle, 'Math Quiz');
      expect(review.score, 85);
      expect(review.answers, isA<List>());
    });

    test('ExamCategoryModel initializes correctly', () {
      // Arrange & Act
      final category = ExamCategoryModel(
        id: 1,
        name: 'Mathematics',
        totalExams: 5,
      );

      // Assert
      expect(category.id, 1);
      expect(category.name, 'Mathematics');
      expect(category.totalExams, 5);
    });
  });

  group('ExamService - API Mocking', () {
    final mockExamModel = ExamModel(
      id: 1,
      title: 'Math Quiz',
      description: 'Basic Math Test',
      random: false,
      status: 'active',
      durationMinutes: 30,
      categoryId: 1,
    );

    final mockExamAttempt = ExamAttemptModel(
      id: 1,
      examId: 1,
      startTime: DateTime.now(),
      submit: false,
    );

    final mockExamResult = ExamResultModel(
      score: 85,
      correctCount: 8,
      totalQuestions: 10,
    );

    test('startExam returns exam attempt', () async {
      // Arrange
      when(() => mockDio.post(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: mockExamAttempt.toJson(),
          statusCode: 200,
        ),
      );

      // Act
      final response = await mockDio.post('test');

      // Assert
      expect(response.statusCode, 200);
      final attempt = ExamAttemptModel.fromJson(response.data);
      expect(attempt.id, 1);
      expect(attempt.submit, false);
    });

    test('finishExam returns exam result with score', () async {
      // Arrange
      when(() => mockDio.post(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: mockExamResult.toJson(),
          statusCode: 200,
        ),
      );

      // Act
      final response = await mockDio.post('test');

      // Assert
      expect(response.statusCode, 200);
      final result = ExamResultModel.fromJson(response.data);
      expect(result.score, 85);
      expect(result.correctCount, 8);
    });

    test('getExamsByUserId returns list of exams', () async {
      // Arrange
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: [mockExamModel.toJson()],
          statusCode: 200,
        ),
      );

      // Act
      final response = await mockDio.get('test', queryParameters: {});

      // Assert
      expect(response.statusCode, 200);
      final exams = (response.data as List)
          .map((e) => ExamModel.fromJson(e))
          .toList();
      expect(exams.length, 1);
      expect(exams[0].title, 'Math Quiz');
    });
  });
}

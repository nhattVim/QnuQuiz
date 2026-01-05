import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/exam_attempt_model.dart';
import 'package:frontend/models/exam_result_model.dart';
import 'package:frontend/models/exam_review_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/exam_service.dart';
import 'package:mocktail/mocktail.dart';

class MockApiService extends Mock implements ApiService {}

class MockDio extends Mock implements Dio {}

void main() {
  late ExamService examService;
  late MockDio mockDio;
  late MockApiService mockApiService;

  setUp(() {
    mockDio = MockDio();
    mockApiService = MockApiService();
    when(() => mockApiService.dio).thenReturn(mockDio);
    examService = ExamService(mockApiService);
  });

  group('Quiz/Exam Attempt Operations', () {
    final mockAttempt = ExamAttemptModel(
      id: 1,
      examId: 100,
      startTime: DateTime.now(),
      submit: false,
    );

    final mockResult = ExamResultModel(
      score: 85,
      correctCount: 8,
      totalQuestions: 10,
    );

    final mockReview = ExamReviewModel(
      examAttemptId: 1,
      examTitle: 'Math Quiz',
      score: 85,
      answers: [],
    );

    group('startExam workflow', () {
      test('returns exam attempt on success', () async {
        when(() => mockDio.post(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: mockAttempt.toJson(),
            statusCode: 200,
          ),
        );

        final result = await examService.startExam(100);

        expect(result, isA<ExamAttemptModel>());
        expect(result.id, mockAttempt.id);
        expect(result.submit, false);
      });

      test('throws exception on DioException', () async {
        when(() => mockDio.post(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              data: {'message': 'Start failed'},
              statusCode: 400,
            ),
          ),
        );

        expect(() => examService.startExam(100), throwsException);
      });
    });

    group('submitAnswer workflow', () {
      test('handles single answer submission', () async {
        when(() => mockDio.post(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          ),
        );

        await examService.submitAnswer(
          attemptId: 1,
          questionId: 1,
          optionId: 1,
        );

        verify(() => mockDio.post(any())).called(1);
      });

      test('validates multiple question submissions', () async {
        final questionIds = [1, 2, 3, 4, 5];
        final optionIds = [1, 2, 3, 1, 2];

        expect(questionIds.length, optionIds.length);
        expect(questionIds.length, 5);
      });

      test('throws exception on invalid submission', () async {
        when(() => mockDio.post(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              data: {'message': 'Invalid answer'},
              statusCode: 400,
            ),
          ),
        );

        expect(
          () => examService.submitAnswer(
            attemptId: 1,
            questionId: 1,
            optionId: 999,
          ),
          throwsException,
        );
      });
    });

    group('finishExam workflow', () {
      test('returns result with score on success', () async {
        when(() => mockDio.post(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: mockResult.toJson(),
            statusCode: 200,
          ),
        );

        final result = await examService.finishExam(1);

        expect(result, isA<ExamResultModel>());
        expect(result.score, mockResult.score);
        expect(result.correctCount, mockResult.correctCount);
      });

      test('throws exception on DioException', () async {
        when(() => mockDio.post(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              data: {'message': 'Finish failed'},
              statusCode: 400,
            ),
          ),
        );

        expect(() => examService.finishExam(1), throwsException);
      });
    });

    group('reviewExamAttempt workflow', () {
      test('returns exam review on success', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: mockReview.toJson(),
            statusCode: 200,
          ),
        );

        final result = await examService.reviewExamAttempt(1);

        expect(result, isA<ExamReviewModel>());
        expect(result.examAttemptId, mockReview.examAttemptId);
        expect(result.score, mockReview.score);
      });

      test('throws exception on DioException', () async {
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              data: {'message': 'Review failed'},
              statusCode: 500,
            ),
          ),
        );

        expect(() => examService.reviewExamAttempt(1), throwsException);
      });
    });
  });

  group('Quiz Result Validation', () {
    test('exam result has valid score range', () {
      final result = ExamResultModel(
        score: 85,
        correctCount: 8,
        totalQuestions: 10,
      );

      expect(result.score, greaterThanOrEqualTo(0));
      expect(result.score, lessThanOrEqualTo(100));
      expect(result.correctCount, lessThanOrEqualTo(result.totalQuestions));
    });

    test('score percentage calculation', () {
      final result = ExamResultModel(
        score: 85,
        correctCount: 8,
        totalQuestions: 10,
      );

      final percentage = (result.correctCount / result.totalQuestions) * 100;

      expect(percentage, 80.0);
      expect(result.score, greaterThanOrEqualTo(percentage.toInt()));
    });

    test('perfect score condition', () {
      final perfectResult = ExamResultModel(
        score: 100,
        correctCount: 10,
        totalQuestions: 10,
      );

      expect(perfectResult.score, 100);
      expect(perfectResult.correctCount, perfectResult.totalQuestions);
    });

    test('zero score condition', () {
      final zeroResult = ExamResultModel(
        score: 0,
        correctCount: 0,
        totalQuestions: 10,
      );

      expect(zeroResult.score, 0);
      expect(zeroResult.correctCount, 0);
    });
  });

  group('Model Serialization', () {
    test('ExamAttemptModel serialization/deserialization', () {
      final attempt = ExamAttemptModel(
        id: 1,
        examId: 100,
        startTime: DateTime.now(),
        submit: false,
      );
      final json = attempt.toJson();
      final deserialized = ExamAttemptModel.fromJson(json);

      expect(deserialized.id, attempt.id);
      expect(deserialized.examId, attempt.examId);
      expect(deserialized.submit, attempt.submit);
    });

    test('ExamResultModel serialization/deserialization', () {
      final result = ExamResultModel(
        score: 85,
        correctCount: 8,
        totalQuestions: 10,
      );
      final json = result.toJson();
      final deserialized = ExamResultModel.fromJson(json);

      expect(deserialized.score, result.score);
      expect(deserialized.correctCount, result.correctCount);
      expect(deserialized.totalQuestions, result.totalQuestions);
    });

    test('ExamReviewModel serialization/deserialization', () {
      final review = ExamReviewModel(
        examAttemptId: 1,
        examTitle: 'Math Quiz',
        score: 85,
        answers: [],
      );
      final json = review.toJson();
      final deserialized = ExamReviewModel.fromJson(json);

      expect(deserialized.examAttemptId, review.examAttemptId);
      expect(deserialized.examTitle, review.examTitle);
      expect(deserialized.score, review.score);
    });
  });
}

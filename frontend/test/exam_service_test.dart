import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/exam_attempt_model.dart';
import 'package:frontend/models/exam_category_model.dart';
import 'package:frontend/models/exam_model.dart';
import 'package:frontend/models/exam_result_model.dart';
import 'package:frontend/models/exam_review_model.dart';
import 'package:frontend/models/question_model.dart';
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

  group('ExamService', () {
    final examModel = ExamModel(
      id: 1,
      title: 'Math Quiz',
      description: 'Basic Math Test',
      random: false,
      status: 'active',
      durationMinutes: 30,
      categoryId: 1,
    );

    final examAttemptModel = ExamAttemptModel(
      id: 1,
      examId: 1,
      startTime: DateTime.now(),
      submit: false,
    );

    final examResultModel = ExamResultModel(
      score: 85,
      correctCount: 8,
      totalQuestions: 10,
    );

    final examReviewModel = ExamReviewModel(
      examAttemptId: 1,
      examTitle: 'Math Quiz',
      score: 85,
      answers: [],
    );

    final examCategoryModel = ExamCategoryModel(
      id: 1,
      name: 'Mathematics',
      totalExams: 5,
    );

    final questionModel = QuestionModel(
      id: 1,
      content: 'What is 2+2?',
      type: 'SINGLE_CHOICE',
      options: [],
    );

    group('getExamsByUserId', () {
      test('returns list of exams on success', () async {
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [examModel.toJson()],
            statusCode: 200,
          ),
        );

        final result = await examService.getExamsByUserId(true);

        expect(result, isA<List<ExamModel>>());
        expect(result.length, 1);
        expect(result[0].title, examModel.title);
      });

      test('throws exception on DioException', () async {
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              data: {'message': 'Fetch failed'},
              statusCode: 500,
            ),
          ),
        );

        expect(() => examService.getExamsByUserId(true), throwsException);
      });
    });

    group('createExam', () {
      test('returns created ExamModel on success', () async {
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: examModel.toJson(),
            statusCode: 200,
          ),
        );

        final result = await examService.createExam(examModel);

        expect(result, isA<ExamModel>());
        expect(result.title, examModel.title);
      });

      test('throws exception on DioException', () async {
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              data: {'message': 'Creation failed'},
              statusCode: 400,
            ),
          ),
        );

        expect(() => examService.createExam(examModel), throwsException);
      });
    });

    group('updateExam', () {
      test('returns updated ExamModel on success', () async {
        when(() => mockDio.put(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: examModel.toJson(),
            statusCode: 200,
          ),
        );

        final result = await examService.updateExam(examModel);

        expect(result, isA<ExamModel>());
        expect(result.id, examModel.id);
      });

      test('throws exception on DioException', () async {
        when(() => mockDio.put(any(), data: any(named: 'data'))).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              data: {'message': 'Update failed'},
              statusCode: 400,
            ),
          ),
        );

        expect(() => examService.updateExam(examModel), throwsException);
      });
    });

    group('deleteExam', () {
      test('completes successfully on delete', () async {
        when(() => mockDio.delete(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          ),
        );

        await examService.deleteExam(1);

        verify(() => mockDio.delete(any())).called(1);
      });

      test('throws exception on DioException', () async {
        when(() => mockDio.delete(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              data: {'message': 'Delete failed'},
              statusCode: 500,
            ),
          ),
        );

        expect(() => examService.deleteExam(1), throwsException);
      });
    });

    group('getAllExams', () {
      test('returns list of all exams on success', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [examModel.toJson()],
            statusCode: 200,
          ),
        );

        final result = await examService.getAllExams();

        expect(result, isA<List<ExamModel>>());
        expect(result.length, 1);
      });

      test('throws exception on DioException', () async {
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              data: {'message': 'Fetch failed'},
              statusCode: 500,
            ),
          ),
        );

        expect(() => examService.getAllExams(), throwsException);
      });
    });

    group('getAllCategories', () {
      test('returns list of categories on success', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [examCategoryModel.toJson()],
            statusCode: 200,
          ),
        );

        final result = await examService.getAllCategories();

        expect(result, isA<List<ExamCategoryModel>>());
        expect(result.length, 1);
        expect(result[0].name, examCategoryModel.name);
      });

      test('throws exception on DioException', () async {
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              data: {'message': 'Fetch failed'},
              statusCode: 500,
            ),
          ),
        );

        expect(() => examService.getAllCategories(), throwsException);
      });
    });

    group('getExamsByCategory', () {
      test('returns list of exams for a category on success', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [examModel.toJson()],
            statusCode: 200,
          ),
        );

        final result = await examService.getExamsByCategory(1);

        expect(result, isA<List<ExamModel>>());
        expect(result.length, 1);
      });

      test('throws exception on DioException', () async {
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              data: {'message': 'Fetch failed'},
              statusCode: 500,
            ),
          ),
        );

        expect(() => examService.getExamsByCategory(1), throwsException);
      });
    });

    group('startExam', () {
      test('returns ExamAttemptModel on success', () async {
        when(() => mockDio.post(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: examAttemptModel.toJson(),
            statusCode: 200,
          ),
        );

        final result = await examService.startExam(1);

        expect(result, isA<ExamAttemptModel>());
        expect(result.examId, examAttemptModel.examId);
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

        expect(() => examService.startExam(1), throwsException);
      });
    });

    group('submitAnswer', () {
      test('completes successfully', () async {
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

      test('throws exception on DioException', () async {
        when(() => mockDio.post(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              data: {'message': 'Submit failed'},
              statusCode: 400,
            ),
          ),
        );

        expect(
          () => examService.submitAnswer(
            attemptId: 1,
            questionId: 1,
            optionId: 1,
          ),
          throwsException,
        );
      });
    });

    group('finishExam', () {
      test('returns ExamResultModel on success', () async {
        when(() => mockDio.post(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: examResultModel.toJson(),
            statusCode: 200,
          ),
        );

        final result = await examService.finishExam(1);

        expect(result, isA<ExamResultModel>());
        expect(result.score, examResultModel.score);
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

    group('reviewExamAttempt', () {
      test('returns ExamReviewModel on success', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: examReviewModel.toJson(),
            statusCode: 200,
          ),
        );

        final result = await examService.reviewExamAttempt(1);

        expect(result, isA<ExamReviewModel>());
        expect(result.examAttemptId, examReviewModel.examAttemptId);
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

    group('getLatestAttempt', () {
      test('returns ExamAttemptModel on success', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: examAttemptModel.toJson(),
            statusCode: 200,
          ),
        );

        final result = await examService.getLatestAttempt(1);

        expect(result, isA<ExamAttemptModel>());
        expect(result.id, examAttemptModel.id);
      });

      test('throws exception on DioException', () async {
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              data: {'message': 'Fetch failed'},
              statusCode: 500,
            ),
          ),
        );

        expect(() => examService.getLatestAttempt(1), throwsException);
      });
    });

    group('getQuestionByExam', () {
      test('returns list of questions on success', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [questionModel.toJson()],
            statusCode: 200,
          ),
        );

        final result = await examService.getQuestionByExam(1);

        expect(result, isA<List<QuestionModel>>());
        expect(result.length, 1);
      });

      test('throws exception on DioException', () async {
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              data: {'message': 'Fetch failed'},
              statusCode: 500,
            ),
          ),
        );

        expect(() => examService.getQuestionByExam(1), throwsException);
      });
    });
  });
}

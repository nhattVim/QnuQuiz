import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/feedbacks/create_feedback_model.dart';
import 'package:frontend/models/feedbacks/feedback_dto.dart';
import 'package:frontend/models/feedbacks/feedback_template_model.dart';
import 'package:frontend/models/feedbacks/teacher_reply_model.dart';
import 'package:frontend/models/feedbacks/update_feedback_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/feedback_service.dart';
import 'package:mocktail/mocktail.dart';

class MockApiService extends Mock implements ApiService {}

class MockDio extends Mock implements Dio {}

void main() {
  late FeedbackService feedbackService;
  late MockDio mockDio;
  late MockApiService mockApiService;

  setUp(() {
    mockDio = MockDio();
    mockApiService = MockApiService();
    when(() => mockApiService.dio).thenReturn(mockDio);
    feedbackService = FeedbackService(mockApiService);
  });

  group('FeedbackService', () {
    final feedbackDto = FeedbackDto(
      id: 1,
      examContent: 'Test Exam',
      content: 'Test feedback',
      rating: 5,
      status: 'PENDING',
      createdAt: DateTime.now(),
      userName: 'Test User',
    );

    final createFeedbackModel = CreateFeedbackModel(
      content: 'New feedback',
      rating: 4,
      examId: 1,
    );

    final updateFeedbackModel = UpdateFeedbackModel(
      content: 'Updated feedback',
      rating: 3,
    );

    final teacherReplyModel = TeacherReplyModel(
      reply: 'Teacher reply',
      status: 'REVIEWED',
    );

    final feedbackTemplateModel = FeedbackTemplateModel(
      code: 'TEMPLATE_1',
      label: 'Template 1',
      content: 'Template content',
    );

    group('getAllFeedbacks', () {
      test('returns list of FeedbackDto on success', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [feedbackDto.toJson()],
            statusCode: 200,
          ),
        );

        final result = await feedbackService.getAllFeedbacks();

        expect(result, isA<List<FeedbackDto>>());
        expect(result.length, 1);
        expect(result[0].content, feedbackDto.content);
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

        expect(() => feedbackService.getAllFeedbacks(), throwsException);
      });
    });

    group('getFeedbacksByCurrentUser', () {
      test('returns list of FeedbackDto for current user', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [feedbackDto.toJson()],
            statusCode: 200,
          ),
        );

        final result = await feedbackService.getFeedbacksByCurrentUser();

        expect(result, isA<List<FeedbackDto>>());
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

        expect(
          () => feedbackService.getFeedbacksByCurrentUser(),
          throwsException,
        );
      });
    });

    group('getFeedbacksForQuestion', () {
      test('returns list of FeedbackDto for a question', () async {
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [feedbackDto.toJson()],
            statusCode: 200,
          ),
        );

        final result = await feedbackService.getFeedbacksForQuestion(1);

        expect(result, isA<List<FeedbackDto>>());
        expect(result.length, 1);
      });

      test('includes status in query parameters when provided', () async {
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [feedbackDto.toJson()],
            statusCode: 200,
          ),
        );

        await feedbackService.getFeedbacksForQuestion(1, status: 'PENDING');

        verify(
          () => mockDio.get(any(), queryParameters: {'status': 'PENDING'}),
        ).called(1);
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

        expect(
          () => feedbackService.getFeedbacksForQuestion(1),
          throwsException,
        );
      });
    });

    group('getFeedbacksForExam', () {
      test('returns list of FeedbackDto for an exam', () async {
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [feedbackDto.toJson()],
            statusCode: 200,
          ),
        );

        final result = await feedbackService.getFeedbacksForExam(1);

        expect(result, isA<List<FeedbackDto>>());
        expect(result.length, 1);
      });

      test('includes status in query parameters when provided', () async {
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [feedbackDto.toJson()],
            statusCode: 200,
          ),
        );

        await feedbackService.getFeedbacksForExam(1, status: 'REVIEWED');

        verify(
          () => mockDio.get(any(), queryParameters: {'status': 'REVIEWED'}),
        ).called(1);
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

        expect(() => feedbackService.getFeedbacksForExam(1), throwsException);
      });
    });

    group('createFeedback', () {
      test('returns FeedbackDto on successful creation', () async {
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: feedbackDto.toJson(),
            statusCode: 201,
          ),
        );

        final result = await feedbackService.createFeedback(
          createFeedbackModel,
        );

        expect(result, isA<FeedbackDto>());
        expect(result.content, feedbackDto.content);
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

        expect(
          () => feedbackService.createFeedback(createFeedbackModel),
          throwsException,
        );
      });
    });

    group('updateFeedback', () {
      test('returns updated FeedbackDto on success', () async {
        when(() => mockDio.put(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: feedbackDto.toJson(),
            statusCode: 200,
          ),
        );

        final result = await feedbackService.updateFeedback(
          1,
          updateFeedbackModel,
        );

        expect(result, isA<FeedbackDto>());
        expect(result.id, feedbackDto.id);
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

        expect(
          () => feedbackService.updateFeedback(1, updateFeedbackModel),
          throwsException,
        );
      });
    });

    group('deleteFeedback', () {
      test('completes successfully on delete', () async {
        when(() => mockDio.delete(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 204,
          ),
        );

        await feedbackService.deleteFeedback(1);

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

        expect(() => feedbackService.deleteFeedback(1), throwsException);
      });
    });

    group('addTeacherReply', () {
      test('returns FeedbackDto with teacher reply on success', () async {
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: feedbackDto.toJson(),
            statusCode: 200,
          ),
        );

        final result = await feedbackService.addTeacherReply(
          1,
          teacherReplyModel,
        );

        expect(result, isA<FeedbackDto>());
        expect(result.id, feedbackDto.id);
      });

      test('throws exception on DioException', () async {
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              data: {'message': 'Reply failed'},
              statusCode: 400,
            ),
          ),
        );

        expect(
          () => feedbackService.addTeacherReply(1, teacherReplyModel),
          throwsException,
        );
      });
    });

    group('getTemplates', () {
      test('returns list of FeedbackTemplateModel on success', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [feedbackTemplateModel.toJson()],
            statusCode: 200,
          ),
        );

        final result = await feedbackService.getTemplates();

        expect(result, isA<List<FeedbackTemplateModel>>());
        expect(result.length, 1);
        expect(result[0].label, feedbackTemplateModel.label);
      });

      test('throws exception on DioException', () async {
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              data: {'message': 'Fetch templates failed'},
              statusCode: 500,
            ),
          ),
        );

        expect(() => feedbackService.getTemplates(), throwsException);
      });
    });
  });
}

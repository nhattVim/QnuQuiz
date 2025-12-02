import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/question_model.dart';
import 'package:frontend/models/question_option_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/question_service.dart';
import 'package:mocktail/mocktail.dart';

class MockApiService extends Mock implements ApiService {}

class MockDio extends Mock implements Dio {}

class MockFile extends Mock implements File {}

void main() {
  late QuestionService questionService;
  late MockDio mockDio;
  late MockApiService mockApiService;

  setUp(() {
    mockDio = MockDio();
    mockApiService = MockApiService();
    when(() => mockApiService.dio).thenReturn(mockDio);
    questionService = QuestionService(mockApiService);
  });

  group('QuestionService', () {
    const examId = 1;
    final question = QuestionModel(
      id: 1,
      content: 'Test question',
      options: [
        QuestionOptionModel(id: 1, content: 'a', correct: true),
        QuestionOptionModel(id: 2, content: 'b', correct: false),
      ],
    );

    test('getQuestions returns a list of questions on success', () async {
      final responseData = [question.toJson()];

      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: responseData,
          statusCode: 200,
        ),
      );

      final result = await questionService.getQuestions(examId);

      expect(result, isA<List<QuestionModel>>());
      expect(result.first.id, question.id);
    });

    test('getQuestions throws an exception on DioException', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            data: {'message': 'Error'},
            statusCode: 500,
          ),
        ),
      );

      expect(() => questionService.getQuestions(examId), throwsException);
    });

    test('importQuestions completes successfully', () async {
      final tempDir = Directory.systemTemp.createTempSync();
      final tempFile = File('${tempDir.path}/test_file.xlsx');
      await tempFile.create(); // Tạo file rỗng trên ổ cứng

      when(
        () => mockDio.post(
          any(),
          queryParameters: any(named: 'queryParameters'),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: {'message': 'Success'},
        ),
      );

      await questionService.importQuestions(tempFile, examId);

      verify(
        () => mockDio.post(
          any(),
          queryParameters: any(named: 'queryParameters'),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).called(1);

      await tempDir.delete(recursive: true);
    });

    test('deleteQuestions completes successfully', () async {
      when(() => mockDio.delete(any(), data: any(named: 'data'))).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(path: ''), statusCode: 200),
      );

      await questionService.deleteQuestions([1, 2, 3]);

      verify(() => mockDio.delete(any(), data: any(named: 'data'))).called(1);
    });

    test('updateQuestion returns updated question on success', () async {
      final responseData = question.toJson();

      when(() => mockDio.put(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: responseData,
          statusCode: 200,
        ),
      );

      final result = await questionService.updateQuestion(question);

      expect(result, isA<QuestionModel>());
      expect(result.id, question.id);
    });
  });
}

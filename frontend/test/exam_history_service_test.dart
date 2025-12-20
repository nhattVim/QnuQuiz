import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/exam_history_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/exam_history_service.dart';
import 'package:mocktail/mocktail.dart';

class MockApiService extends Mock implements ApiService {}

class MockDio extends Mock implements Dio {}

void main() {
  late ExamHistoryService examHistoryService;
  late MockDio mockDio;
  late MockApiService mockApiService;

  setUp(() {
    mockDio = MockDio();
    mockApiService = MockApiService();
    when(() => mockApiService.dio).thenReturn(mockDio);
    examHistoryService = ExamHistoryService(mockApiService);
  });

  group('ExamHistoryService', () {
    final historyModel1 = ExamHistoryModel(
      attemptId: 1,
      examId: 100,
      examTitle: 'Quiz 1',
      examDescription: 'Test Quiz 1',
      score: 80,
      completionDate: DateTime(2025, 11, 26, 10, 30),
      durationMinutes: 30,
    );

    final historyModel2 = ExamHistoryModel(
      attemptId: 2,
      examId: 101,
      examTitle: 'Quiz 2',
      examDescription: 'Test Quiz 2',
      score: 90,
      completionDate: DateTime(2025, 11, 25, 14, 15),
      durationMinutes: 45,
    );

    group('getExamHistory', () {
      test('returns list of exam history on success', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [historyModel1.toJson(), historyModel2.toJson()],
            statusCode: 200,
          ),
        );

        final result = await examHistoryService.getExamHistory();

        expect(result, isA<List<ExamHistoryModel>>());
        expect(result.length, 2);
        expect(result[0].score, historyModel1.score);
        expect(result[1].score, historyModel2.score);
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

        expect(() => examHistoryService.getExamHistory(), throwsException);
      });
    });

    group('ExamHistoryModel validation', () {
      test('serialization/deserialization', () {
        final json = historyModel1.toJson();
        final deserialized = ExamHistoryModel.fromJson(json);

        expect(deserialized.attemptId, historyModel1.attemptId);
        expect(deserialized.examId, historyModel1.examId);
        expect(deserialized.score, historyModel1.score);
        expect(deserialized.durationMinutes, historyModel1.durationMinutes);
      });

      test('calculate pass/fail from score', () {
        const passingScore = 50;
        final isPassed = (historyModel1.score ?? 0) >= passingScore;

        expect(isPassed, true);
        expect(historyModel1.score, greaterThanOrEqualTo(passingScore));
      });

      test('sorting by date descending', () {
        final historyList = [historyModel1, historyModel2];
        final sorted = List.from(historyList)
          ..sort((a, b) => b.completionDate!.compareTo(a.completionDate!));

        expect(sorted[0].attemptId, 1); // Nov 26
        expect(sorted[1].attemptId, 2); // Nov 25
      });

      test('calculate highest score for exam', () {
        final historyList = [
          historyModel1, // score 80
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

        final scores = historyList
            .where((h) => h.examId == 100)
            .map((h) => h.score ?? 0)
            .toList();
        final maxScore = scores.isNotEmpty
            ? scores.reduce((a, b) => a > b ? a : b)
            : 0;

        expect(maxScore, 95);
      });

      test('calculate average score for exam', () {
        final historyList = [
          historyModel1, // score 80
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

        final attempts = historyList.where((h) => h.examId == 100).toList();
        final scores = attempts.map((h) => h.score ?? 0).toList();
        final avgScore = attempts.isNotEmpty
            ? scores.reduce((a, b) => a + b) / attempts.length
            : 0;

        expect(avgScore, 85);
      });

      test('count attempts for specific exam', () {
        final historyList = [
          historyModel1,
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

        final attempts = historyList.where((h) => h.examId == 100).length;

        expect(attempts, 2);
      });
    });
  });
}

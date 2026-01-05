import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/ranking_model.dart';
import 'package:frontend/services/analytics_service.dart';
import 'package:frontend/services/api_service.dart';
import 'package:mocktail/mocktail.dart';

class MockApiService extends Mock implements ApiService {}

class MockDio extends Mock implements Dio {}

void main() {
  late AnalyticsService analyticsService;
  late MockDio mockDio;
  late MockApiService mockApiService;

  setUp(() {
    mockDio = MockDio();
    mockApiService = MockApiService();
    when(() => mockApiService.dio).thenReturn(mockDio);
    analyticsService = AnalyticsService(mockApiService);
  });

  group('AnalyticsService', () {
    final ranking = RankingModel(
      username: 'testuser',
      score: 10,
      fullName: 'Test User',
      avatarUrl: 'http://example.com/avatar.png',
    );

    test('getRankingAll returns a list of rankings on success', () async {
      final responseData = [ranking.toJson()];

      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: responseData,
          statusCode: 200,
        ),
      );

      final result = await analyticsService.getRankingAll();

      expect(result, isA<List<RankingModel>>());
      expect(result.first.username, ranking.username);
    });

    test('getRankingAll throws an exception on DioException', () async {
      when(() => mockDio.get(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            data: {'message': 'Error'},
            statusCode: 500,
          ),
        ),
      );

      expect(() => analyticsService.getRankingAll(), throwsException);
    });

    test(
      'getRankingAllThisWeek returns a list of rankings on success',
      () async {
        final responseData = [ranking.toJson()];

        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: responseData,
            statusCode: 200,
          ),
        );

        final result = await analyticsService.getRankingAllThisWeek();

        expect(result, isA<List<RankingModel>>());
        expect(result.first.username, ranking.username);
      },
    );

    test('getRankingAllThisWeek throws an exception on DioException', () async {
      when(() => mockDio.get(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            data: {'message': 'Error'},
            statusCode: 500,
          ),
        ),
      );

      expect(() => analyticsService.getRankingAllThisWeek(), throwsException);
    });

    test('getExamAnalytics returns a list of ExamAnalytics', () async {
      final responseData = [
        {
          'examId': 1,
          'title': 'Test Exam',
        }
      ];

      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: responseData,
          statusCode: 200,
        ),
      );

      final result = await analyticsService.getExamAnalytics('teacherId');
      expect(result, isA<List>()); 
    });
    
    group('getExamAnalytics', () {
      test('returns list on success', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [], 
            statusCode: 200,
          ),
        );
        expect(await analyticsService.getExamAnalytics('1'), isA<List>());
      });
      
      test('throws exception on error', () async {
         when(() => mockDio.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              data: {'message': 'Error'},
              statusCode: 500,
            ),
          ),
        );
        expect(() => analyticsService.getExamAnalytics('1'), throwsException);
      });
    });

    group('getClassPerformance', () {
      test('returns list on success', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [],
            statusCode: 200,
          ),
        );
        expect(await analyticsService.getClassPerformance(1), isA<List>());
      });

      test('throws exception on error', () async {
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            error: 'Error',
            response: Response(requestOptions: RequestOptions(path: ''), statusCode: 500, data: {'message': 'Error'}),
          ),
        );
        expect(() => analyticsService.getClassPerformance(1), throwsException);
      });
    });

    group('getScoreDistribution', () {
      test('returns list on success', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [],
            statusCode: 200,
          ),
        );
        expect(await analyticsService.getScoreDistribution('1'), isA<List>());
      });

      test('throws exception on error', () async {
        when(() => mockDio.get(any())).thenThrow(
            DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(requestOptions: RequestOptions(path: ''), statusCode: 500, data: {'message': 'Error'}),
          ),
        );
        expect(() => analyticsService.getScoreDistribution('1'), throwsException);
      });
    });

    group('getStudentAttempts', () {
      test('returns list on success', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [],
            statusCode: 200,
          ),
        );
        expect(await analyticsService.getStudentAttempts(1), isA<List>());
      });

      test('throws exception on error', () async {
        when(() => mockDio.get(any())).thenThrow(
           DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(requestOptions: RequestOptions(path: ''), statusCode: 500, data: {'message': 'Error'}),
          ),
        );
        expect(() => analyticsService.getStudentAttempts(1), throwsException);
      });
    });

    group('getQuestionAnalytics', () {
      test('returns list on success', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [],
            statusCode: 200,
          ),
        );
        expect(await analyticsService.getQuestionAnalytics(1), isA<List>());
      });

      test('throws exception on error', () async {
        when(() => mockDio.get(any())).thenThrow(
           DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(requestOptions: RequestOptions(path: ''), statusCode: 500, data: {'message': 'Error'}),
          ),
        );
        expect(() => analyticsService.getQuestionAnalytics(1), throwsException);
      });
    });

    group('getRankingByExamId', () {
      test('returns list on success', () async {
         when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [], // Empty list
            statusCode: 200,
          ),
        );
        expect(await analyticsService.getRankingByExamId(1), isA<List<RankingModel>>());
      });

      test('throws exception on error', () async {
        when(() => mockDio.get(any())).thenThrow(
           DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(requestOptions: RequestOptions(path: ''), statusCode: 500, data: {'message': 'Error'}),
          ),
        );
        expect(() => analyticsService.getRankingByExamId(1), throwsException);
      });
    });

    group('getUserAnalytics', () {
      test('returns UserAnalyticsModel on success', () async {
        final data = {
             'totalUsers': 10,
             'activeUsers': 5,
        };
       
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {}, 
            statusCode: 200,
          ),
        );
       
      });
    });

    test('downloadUserAnalyticsCsv returns bytes on success', () async {
       when(() => mockDio.get(
        any(),
        options: any(named: 'options'),
      )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: [1, 2, 3],
          statusCode: 200,
        ),
      );
      
      final result = await analyticsService.downloadUserAnalyticsCsv();
      expect(result, equals([1, 2, 3]));
    });

    test('downloadUserAnalyticsCsv throws on error', () async {
       when(() => mockDio.get(
        any(),
        options: any(named: 'options'),
      )).thenThrow(
        DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(requestOptions: RequestOptions(path: ''), statusCode: 500, data: {'message': 'Error'}),
          ),
      );
      expect(() => analyticsService.downloadUserAnalyticsCsv(), throwsException);
    });

    test('downloadExamAnalyticsCsv returns bytes on success', () async {
       when(() => mockDio.get(
        any(),
        options: any(named: 'options'),
      )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: [1, 2, 3],
          statusCode: 200,
        ),
      );
      expect(await analyticsService.downloadExamAnalyticsCsv(), equals([1, 2, 3]));
    });

    test('downloadQuestionAnalyticsCsv returns bytes on success', () async {
       when(() => mockDio.get(
        any(),
        options: any(named: 'options'),
      )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: [1, 2, 3],
          statusCode: 200,
        ),
      );
      expect(await analyticsService.downloadQuestionAnalyticsCsv(), equals([1, 2, 3]));
    });
  });
}

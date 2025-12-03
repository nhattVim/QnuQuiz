import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/ranking_model.dart';
import 'package:frontend/services/analytics_service.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late AnalyticsService analyticsService;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    analyticsService = AnalyticsService(dio: mockDio);
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
  });
}


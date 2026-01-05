import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/announcement_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/announcement_service.dart';
import 'package:mocktail/mocktail.dart';

class MockApiService extends Mock implements ApiService {}

class MockDio extends Mock implements Dio {}

void main() {
  late AnnouncementService announcementService;
  late MockDio mockDio;
  late MockApiService mockApiService;

  setUp(() {
    mockDio = MockDio();
    mockApiService = MockApiService();
    when(() => mockApiService.dio).thenReturn(mockDio);
    announcementService = AnnouncementService(mockApiService);
  });

  group('AnnouncementService', () {
    final now = DateTime.now();
    final announcementModel = AnnouncementModel(
      id: 1,
      title: 'Thông báo thi cuối kỳ',
      content: 'Lịch thi cuối kỳ sẽ được công bố vào tuần tới',
      target: 'ALL',
      publishedAt: now,
      createdAt: now,
      authorName: 'Admin',
    );

    group('S6.1 - getAnnouncements', () {
      test('returns list of announcements on success (STUDENT)', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [announcementModel.toJson()],
            statusCode: 200,
          ),
        );

        final result = await announcementService.getAnnouncements(role: 'STUDENT');

        expect(result, isA<List<AnnouncementModel>>());
        expect(result.length, 1);
        expect(result[0].title, announcementModel.title);
        expect(result[0].content, announcementModel.content);
      });

      test('returns empty list when no announcements (STUDENT)', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [],
            statusCode: 200,
          ),
        );

        final result = await announcementService.getAnnouncements(role: 'STUDENT');

        expect(result, isA<List<AnnouncementModel>>());
        expect(result.length, 0);
      });

      test('returns empty list when data is not a list (STUDENT)', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {},
            statusCode: 200,
          ),
        );

        final result = await announcementService.getAnnouncements(role: 'STUDENT');

        expect(result, isA<List<AnnouncementModel>>());
        expect(result.length, 0);
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

        expect(() => announcementService.getAnnouncements(role: 'STUDENT'), throwsException);
      });
    });

    group('S6.2 - createAnnouncement', () {
      test('returns AnnouncementModel on success (target = ALL)', () async {
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: announcementModel.toJson(),
            statusCode: 200,
          ),
        );

        final result = await announcementService.createAnnouncement(
          title: 'Thông báo thi cuối kỳ',
          content: 'Lịch thi cuối kỳ sẽ được công bố vào tuần tới',
          target: 'ALL',
        );

        expect(result, isA<AnnouncementModel>());
        expect(result.title, announcementModel.title);
        expect(result.target, 'ALL');
      });

      test('includes classId when target is CLASS', () async {
        final classNow = DateTime.now();
        final classAnnouncement = AnnouncementModel(
          id: 2,
          title: 'Thông báo lớp K61',
          content: 'Thông báo dành cho lớp K61',
          target: 'CLASS',
          publishedAt: classNow,
          createdAt: classNow,
          authorName: 'Teacher',
          classId: 1,
          className: 'K61',
        );

        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: classAnnouncement.toJson(),
            statusCode: 200,
          ),
        );

        await announcementService.createAnnouncement(
          title: 'Thông báo lớp K61',
          content: 'Thông báo dành cho lớp K61',
          target: 'CLASS',
          classId: 1,
        );

        verify(
          () => mockDio.post(
            any(),
            data: {
              'title': 'Thông báo lớp K61',
              'content': 'Thông báo dành cho lớp K61',
              'target': 'CLASS',
              'classId': 1,
            },
          ),
        ).called(1);
      });

      test('includes departmentId when target is DEPARTMENT', () async {
        final deptNow = DateTime.now();
        final deptAnnouncement = AnnouncementModel(
          id: 3,
          title: 'Thông báo khoa CNTT',
          content: 'Thông báo dành cho khoa CNTT',
          target: 'DEPARTMENT',
          publishedAt: deptNow,
          createdAt: deptNow,
          authorName: 'Teacher',
          departmentId: 1,
          departmentName: 'Khoa CNTT',
        );

        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: deptAnnouncement.toJson(),
            statusCode: 200,
          ),
        );

        await announcementService.createAnnouncement(
          title: 'Thông báo khoa CNTT',
          content: 'Thông báo dành cho khoa CNTT',
          target: 'DEPARTMENT',
          departmentId: 1,
        );

        verify(
          () => mockDio.post(
            any(),
            data: {
              'title': 'Thông báo khoa CNTT',
              'content': 'Thông báo dành cho khoa CNTT',
              'target': 'DEPARTMENT',
              'departmentId': 1,
            },
          ),
        ).called(1);
      });

      test('does not include classId/departmentId when target is ALL', () async {
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: announcementModel.toJson(),
            statusCode: 200,
          ),
        );

        await announcementService.createAnnouncement(
          title: 'Thông báo',
          content: 'Nội dung',
          target: 'ALL',
        );

        verify(
          () => mockDio.post(
            any(),
            data: {
              'title': 'Thông báo',
              'content': 'Nội dung',
              'target': 'ALL',
            },
          ),
        ).called(1);
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
          () => announcementService.createAnnouncement(
            title: 'Title',
            content: 'Content',
            target: 'ALL',
          ),
          throwsException,
        );
      });
    });
  });
}


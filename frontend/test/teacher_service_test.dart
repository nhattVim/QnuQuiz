import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/teacher_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/teacher_service.dart';
import 'package:mocktail/mocktail.dart';

class MockApiService extends Mock implements ApiService {}

class MockDio extends Mock implements Dio {}

void main() {
  late TeacherService teacherService;
  late MockDio mockDio;
  late MockApiService mockApiService;

  setUp(() {
    mockDio = MockDio();
    mockApiService = MockApiService();
    when(() => mockApiService.dio).thenReturn(mockDio);
    teacherService = TeacherService(mockApiService);
  });

  group('TeacherService', () {
    final teacherModel = TeacherModel(
      id: 1,
      username: 'teacher1',
      email: 'teacher@example.com',
      teacherCode: 'T001',
      fullName: 'Test Teacher',
      phoneNumber: '123456789',
      departmentId: 1,
      title: 'Professor',
    );

    group('S1.4 - updateProfile', () {
      test('returns updated TeacherModel on success', () async {
        when(() => mockDio.put(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: teacherModel.toJson(),
            statusCode: 200,
          ),
        );

        final result = await teacherService.updateProfile(
          fullName: 'Updated Teacher',
          email: 'updated@example.com',
          phoneNumber: '987654321',
          departmentId: 1,
          title: 'Associate Professor',
        );

        expect(result, isA<TeacherModel>());
        expect(result.fullName, teacherModel.fullName);
        expect(result.email, teacherModel.email);
        expect(result.title, teacherModel.title);
      });

      test('includes avatarUrl when provided', () async {
        when(() => mockDio.put(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: teacherModel.toJson(),
            statusCode: 200,
          ),
        );

        await teacherService.updateProfile(
          fullName: 'Teacher',
          email: 'teacher@example.com',
          phoneNumber: '123456789',
          departmentId: 1,
          title: 'Professor',
          avatarUrl: 'http://example.com/avatar.png',
        );

        verify(
          () => mockDio.put(
            any(),
            data: {
              'fullName': 'Teacher',
              'email': 'teacher@example.com',
              'phoneNumber': '123456789',
              'departmentId': 1,
              'title': 'Professor',
              'avatarUrl': 'http://example.com/avatar.png',
            },
          ),
        ).called(1);
      });

      test('does not include avatarUrl when null or empty', () async {
        when(() => mockDio.put(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: teacherModel.toJson(),
            statusCode: 200,
          ),
        );

        await teacherService.updateProfile(
          fullName: 'Teacher',
          email: 'teacher@example.com',
          phoneNumber: '123456789',
          departmentId: 1,
          title: 'Professor',
        );

        verify(
          () => mockDio.put(
            any(),
            data: {
              'fullName': 'Teacher',
              'email': 'teacher@example.com',
              'phoneNumber': '123456789',
              'departmentId': 1,
              'title': 'Professor',
            },
          ),
        ).called(1);
      });

      test('throws exception on DioException', () async {
        when(() => mockDio.put(any(), data: any(named: 'data'))).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              data: {'message': 'Update failed'},
              statusCode: 500,
            ),
          ),
        );

        expect(
          () => teacherService.updateProfile(
            fullName: 'Teacher',
            email: 'teacher@example.com',
            phoneNumber: '123456789',
            departmentId: 1,
            title: 'Professor',
          ),
          throwsException,
        );
      });
    });
  });
}


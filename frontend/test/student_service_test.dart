import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/exam_history_model.dart';
import 'package:frontend/models/student_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/student_service.dart';
import 'package:mocktail/mocktail.dart';

class MockApiService extends Mock implements ApiService {}

class MockDio extends Mock implements Dio {}

void main() {
  late StudentService studentService;
  late MockDio mockDio;
  late MockApiService mockApiService;

  setUp(() {
    mockDio = MockDio();
    mockApiService = MockApiService();
    when(() => mockApiService.dio).thenReturn(mockDio);
    studentService = StudentService(mockApiService);
  });

  group('StudentService', () {
    final studentModel = StudentModel(
      id: 1,
      username: 'student1',
      email: 'student@example.com',
      fullName: 'Test Student',
      phoneNumber: '123456789',
      departmentId: 1,
      classId: 1,
    );

    group('S1.4 - updateProfile', () {
      test('returns updated StudentModel on success', () async {
        when(() => mockDio.put(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: studentModel.toJson(),
            statusCode: 200,
          ),
        );

        final result = await studentService.updateProfile(
          fullName: 'Updated Student',
          email: 'updated@example.com',
          phoneNumber: '987654321',
          departmentId: 1,
          classId: 1,
        );

        expect(result, isA<StudentModel>());
        expect(result.fullName, studentModel.fullName);
        expect(result.email, studentModel.email);
      });

      test('includes avatarUrl when provided', () async {
        when(() => mockDio.put(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: studentModel.toJson(),
            statusCode: 200,
          ),
        );

        await studentService.updateProfile(
          fullName: 'Student',
          email: 'student@example.com',
          phoneNumber: '123456789',
          departmentId: 1,
          classId: 1,
          avatarUrl: 'http://example.com/avatar.png',
        );

        verify(
          () => mockDio.put(
            any(),
            data: {
              'fullName': 'Student',
              'email': 'student@example.com',
              'phoneNumber': '123456789',
              'departmentId': 1,
              'classId': 1,
              'avatarUrl': 'http://example.com/avatar.png',
            },
          ),
        ).called(1);
      });

      test('does not include avatarUrl when null or empty', () async {
        when(() => mockDio.put(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: studentModel.toJson(),
            statusCode: 200,
          ),
        );

        await studentService.updateProfile(
          fullName: 'Student',
          email: 'student@example.com',
          phoneNumber: '123456789',
          departmentId: 1,
          classId: 1,
        );

        verify(
          () => mockDio.put(
            any(),
            data: {
              'fullName': 'Student',
              'email': 'student@example.com',
              'phoneNumber': '123456789',
              'departmentId': 1,
              'classId': 1,
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
          () => studentService.updateProfile(
            fullName: 'Student',
            email: 'student@example.com',
            phoneNumber: '123456789',
            departmentId: 1,
            classId: 1,
          ),
          throwsException,
        );
      });
    });

    group('S3.6 - getExamHistory', () {
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

      test('returns list of exam history on success', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [historyModel1.toJson(), historyModel2.toJson()],
            statusCode: 200,
          ),
        );

        final result = await studentService.getExamHistory();

        expect(result, isA<List<ExamHistoryModel>>());
        expect(result.length, 2);
        expect(result[0].score, historyModel1.score);
        expect(result[1].score, historyModel2.score);
      });

      test('returns empty list when no history', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [],
            statusCode: 200,
          ),
        );

        final result = await studentService.getExamHistory();

        expect(result, isA<List<ExamHistoryModel>>());
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

        expect(() => studentService.getExamHistory(), throwsException);
      });
    });
  });
}


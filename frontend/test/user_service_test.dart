import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/student_model.dart';
import 'package:frontend/models/teacher_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/services/user_service.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late UserService userService;
  late MockDio mockDio;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockDio = MockDio();
    mockStorage = MockFlutterSecureStorage();
    userService = UserService(dio: mockDio, storage: mockStorage);
  });

  group('UserService', () {
    final userModel = UserModel(
      id: '1',
      username: 'testuser',
      email: 'test@example.com',
      role: 'STUDENT',
    );
    final studentModel = StudentModel(
      id: 1,
      username: 'testuser',
      email: 'test@example.com',
      fullName: 'Test Student',
      phoneNumber: '123456789',
    );
    final teacherModel = TeacherModel(
      id: 1,
      username: 'testuser',
      email: 'test@example.com',
      teacherCode: '456',
      fullName: 'Test Teacher',
      phoneNumber: '987654321',
    );

    test('clearUser clears the user from storage', () async {
      when(() => mockStorage.delete(key: 'user')).thenAnswer((_) async => {});

      await userService.clearUser();

      verify(() => mockStorage.delete(key: 'user')).called(1);
    });

    test('getUser returns UserModel if data exists in storage', () async {
      when(() => mockStorage.read(key: 'user'))
          .thenAnswer((_) async => jsonEncode(userModel.toJson()));

      final result = await userService.getUser();

      expect(result, isA<UserModel>());
      expect(result!.username, userModel.username);
    });

    test('getUser returns null if no data in storage', () async {
      when(() => mockStorage.read(key: 'user')).thenAnswer((_) async => null);

      final result = await userService.getUser();

      expect(result, null);
    });

    test('saveUser saves the user to storage', () async {
      when(() => mockStorage.write(key: 'user', value: any(named: 'value')))
          .thenAnswer((_) async => {});

      await userService.saveUser(userModel);

      verify(() =>
              mockStorage.write(key: 'user', value: jsonEncode(userModel.toJson())))
          .called(1);
    });

    test('updateProfile returns updated UserModel on success', () async {
      final updatedUser = UserModel(
        id: '1',
        username: 'testuser',
        email: 'new@example.com',
        role: 'STUDENT',
      );
      when(() => mockDio.put(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: updatedUser.toJson(),
          statusCode: 200,
        ),
      );

      final result = await userService.updateProfile(
        fullName: 'New Name',
        email: 'new@example.com',
        phoneNumber: '111222333',
        newPassword: 'newpassword',
      );

      expect(result, isA<UserModel>());
      expect(result.email, updatedUser.email);
    });

    test('updateProfile throws an exception on DioException', () async {
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
        () => userService.updateProfile(
          fullName: 'New Name',
          email: 'new@example.com',
          phoneNumber: '111222333',
        ),
        throwsException,
      );
    });

    group('getCurrentUserProfile', () {
      test('returns StudentModel for STUDENT role', () async {
        when(() => mockStorage.read(key: 'user'))
            .thenAnswer((_) async => jsonEncode(userModel.toJson()));
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: studentModel.toJson(),
            statusCode: 200,
          ),
        );

        final result = await userService.getCurrentUserProfile();

        expect(result, isA<StudentModel>());
        expect(result.username, studentModel.username);
      });

      test('returns TeacherModel for TEACHER role', () async {
        final teacherUser =
            UserModel(id: '1', username: 'testuser', email: 'test@example.com', role: 'TEACHER');
        when(() => mockStorage.read(key: 'user'))
            .thenAnswer((_) async => jsonEncode(teacherUser.toJson()));
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: teacherModel.toJson(),
            statusCode: 200,
          ),
        );

        final result = await userService.getCurrentUserProfile();

        expect(result, isA<TeacherModel>());
        expect(result.teacherCode, teacherModel.teacherCode);
      });

      test('returns UserModel for ADMIN role', () async {
        final adminUser =
            UserModel(id: '1', username: 'testuser', email: 'test@example.com', role: 'ADMIN');
        when(() => mockStorage.read(key: 'user'))
            .thenAnswer((_) async => jsonEncode(adminUser.toJson()));
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: adminUser.toJson(),
            statusCode: 200,
          ),
        );

        final result = await userService.getCurrentUserProfile();

        expect(result, isA<UserModel>());
        expect(result.role, adminUser.role);
      });

      test('throws exception on DioException', () async {
        when(() => mockStorage.read(key: 'user'))
            .thenAnswer((_) async => jsonEncode(userModel.toJson()));
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              data: {'message': 'Profile fetch failed'},
              statusCode: 500,
            ),
          ),
        );

        expect(() => userService.getCurrentUserProfile(), throwsException);
      });
    });
  });
}

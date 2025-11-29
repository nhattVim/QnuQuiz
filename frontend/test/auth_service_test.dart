import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late AuthService authService;
  late MockDio mockDio;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockDio = MockDio();
    mockStorage = MockFlutterSecureStorage();
    authService = AuthService(dio: mockDio, storage: mockStorage);
  });

  group('AuthService', () {
    const username = 'testuser';
    const password = 'testpassword';
    final user = UserModel(
      id: '1',
      username: 'testuser',
      email: 'test@example.com',
      role: 'student',
    );

    test('login returns success on 200', () async {
      final responseData = {'token': 'test_token', 'user': user.toJson()};

      when(
        () => mockDio.post(
          any(),
          data: {'username': username, 'password': password},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: responseData,
          statusCode: 200,
        ),
      );

      final result = await authService.login(
        username: username,
        password: password,
      );

      expect(result['success'], true);
      expect(result['token'], 'test_token');
      expect(result['user'], isA<UserModel>());
      expect(result['user'].username, user.username);
    });

    test('login returns failure on DioException', () async {
      final errorResponseData = {'message': 'Invalid credentials'};
      when(
        () => mockDio.post(
          any(),
          data: {'username': username, 'password': password},
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            data: errorResponseData,
            statusCode: 401,
          ),
        ),
      );

      final result = await authService.login(
        username: username,
        password: password,
      );

      expect(result['success'], false);
      expect(result['message'], 'Invalid credentials');
    });

    test('getToken returns token if exists', () async {
      when(
        () => mockStorage.read(key: 'auth_token'),
      ).thenAnswer((_) async => 'test_token');

      final token = await authService.getToken();

      expect(token, 'test_token');
      verify(() => mockStorage.read(key: 'auth_token')).called(1);
    });

    test('getToken returns null if token does not exist', () async {
      when(
        () => mockStorage.read(key: 'auth_token'),
      ).thenAnswer((_) async => null);

      final token = await authService.getToken();

      expect(token, null);
      verify(() => mockStorage.read(key: 'auth_token')).called(1);
    });

    test('isLoggedIn returns true if token exists', () async {
      when(
        () => mockStorage.read(key: 'auth_token'),
      ).thenAnswer((_) async => 'test_token');

      final loggedIn = await authService.isLoggedIn();

      expect(loggedIn, true);
      verify(() => mockStorage.read(key: 'auth_token')).called(1);
    });

    test('isLoggedIn returns false if token does not exist', () async {
      when(
        () => mockStorage.read(key: 'auth_token'),
      ).thenAnswer((_) async => null);

      final loggedIn = await authService.isLoggedIn();

      expect(loggedIn, false);
      verify(() => mockStorage.read(key: 'auth_token')).called(1);
    });

    test('saveToken saves the token', () async {
      when(
        () => mockStorage.write(key: 'auth_token', value: 'new_token'),
      ).thenAnswer((_) async => {});

      await authService.saveToken('new_token');

      verify(
        () => mockStorage.write(key: 'auth_token', value: 'new_token'),
      ).called(1);
    });

    test('logout deletes the token', () async {
      when(
        () => mockStorage.delete(key: 'auth_token'),
      ).thenAnswer((_) async => {});

      await authService.logout();

      verify(() => mockStorage.delete(key: 'auth_token')).called(1);
    });
  });
}

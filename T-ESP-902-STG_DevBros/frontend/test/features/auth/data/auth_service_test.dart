import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:inspiria/features/auth/data/auth_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockClient mockClient;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://api.test.com'));
  });

  setUp(() {
    mockClient = MockClient();
    
    AuthService.client = mockClient;
    AuthService.mockBaseUrl = 'https://api.test.com';
    
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService - Login Tests', () {
    const String email = 'test@example.com';
    const String password = 'password123';

    test('Should return UserResponce with 200 when login is successful', () async {
      final mockResponseBody = json.encode({
        'token': 'fake_token_123',
        'user': {
          'id': 1,
          'email': email,
          'firstname': 'John',
          'lastname': 'Doe',
        }
      });

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(mockResponseBody, 200));

      final result = await AuthService.login(email, password);

      expect(result, isNotNull);
      expect(result!.statusCode, 200);
      expect(result.user?.email, email);
      
      verify(() => mockClient.post(
        any(), 
        headers: any(named: 'headers'), 
        body: any(named: 'body')
      )).called(1);
    });

    test('Should return 401 when credentials are wrong', () async {
      when(() => mockClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response(json.encode({'error': 'Unauthorized'}), 401));

      final result = await AuthService.login(email, 'wrong_pass');

      expect(result?.statusCode, 401);
      expect(result?.errorMessage, 'Unauthorized');
    });

    test('Should return 500 when an exception occurs (Server Crash)', () async {
      when(() => mockClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenThrow(Exception('Network Error'));

      final result = await AuthService.login(email, password);

      expect(result?.statusCode, 500);
      expect(result?.errorMessage, contains('Network Error'));
    });
  });

  group('AuthService - Reset Password Logic', () {
    test('forgetPassword returns 200 on success', () async {
      const String email = 'reset@test.com';
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(json.encode({'message': 'Success'}), 200));

      final result = await AuthService.forgetPassword(email);

      expect(result?.statusCode, 200);
    });
  });
}
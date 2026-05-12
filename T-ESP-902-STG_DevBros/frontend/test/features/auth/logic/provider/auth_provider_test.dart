import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/core/api/entity/user_entity.dart';
import 'package:inspiria/core/api/repository/auth_repository.dart';
import 'package:inspiria/core/api/repository/login_usecase.dart';
import 'package:inspiria/core/api/repository/logout_usecase.dart';
import 'package:inspiria/features/auth/logic/provider/auth_provider.dart';
import 'package:inspiria/main.dart'; 
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockAuthRepository extends Mock implements AuthRepository {}


class MockMyApp extends Mock implements MyApp {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => 'MockMyApp';
}

void main() {
  late AuthProvider authProvider;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockAuthRepository mockAuthRepository;
  late MockMyApp mockMyApp;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockAuthRepository = MockAuthRepository();
    mockMyApp = MockMyApp();

    when(() => mockAuthRepository.authStatus).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthRepository.currentStatus).thenReturn(AuthStatus.unauthenticated);
    when(() => mockAuthRepository.getAccessToken()).thenAnswer((_) async => 'fake_token');

    authProvider = AuthProvider(
      loginUseCase: mockLoginUseCase,
      logoutUseCase: mockLogoutUseCase,
      authRepository: mockAuthRepository,
      create: (_) {},
      child: mockMyApp, 
    );
  });

  group('AuthProvider Tests', () {
    
    test('Initial status check', () {
      expect(authProvider.status, AuthStatus.unauthenticated);
    });

    test('login success updates status', () async {
      const email = 'test@test.com';

      final user = UserEntity(
        id: '1', 
        email: email,
      );

      when(() => mockLoginUseCase.call(any(), any())).thenAnswer((_) async => user);
      when(() => mockAuthRepository.getAccessToken()).thenAnswer((_) async => 'token');

      await authProvider.login(email, 'password');

      expect(authProvider.status, AuthStatus.authenticated);
      expect(authProvider.currentUser?.email, email);
    });
  });
}
import 'package:inspiria/core/api/entity/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<void> logout();
  Future<String?> getAccessToken();
  Future<void> saveAccessToken(String token);
  Future<String?> getRefreshToken();
  Future<void> saveRefreshToken(String token);
  Future<String?> refreshAccessToken();
  Stream<AuthStatus> get authStatus;
  AuthStatus get currentStatus;
}

enum AuthStatus { unknown, authenticated, unauthenticated }

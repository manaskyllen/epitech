import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inspiria/core/api/auth_remote_datasource.dart';
import 'package:inspiria/core/api/entity/user_entity.dart';
import 'package:inspiria/core/api/repository/auth_repository.dart';
import 'package:inspiria/core/api/token_storage.dart';
import 'package:inspiria/core/utils/constant/exceptions.dart';

class AuthRepositoryImpl extends ChangeNotifier implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  }) {
    _initializeAuthStatus();
  }

  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage localDataSource;

  final _authStatusController = StreamController<AuthStatus>.broadcast();
  AuthStatus _currentStatus = AuthStatus.unknown;

  @override
  Stream<AuthStatus> get authStatus => _authStatusController.stream;

  // Méthode pour obtenir l'état actuel de l'authentification
  AuthStatus get currentAuthStatus => _currentStatus;

  Future<void> _initializeAuthStatus() async {
    try {
      final accessToken = await localDataSource.getAccessToken();

      if (accessToken != null) {
        _currentStatus = AuthStatus.authenticated;
      } else {
        _currentStatus = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _currentStatus = AuthStatus.unauthenticated;
      throw Exception('Erreur lors de l\'initialisation du statut d\'auth: $e');
    } finally {
      _authStatusController.add(_currentStatus);
      notifyListeners(); // Notifier les listeners de l'état initial
    }
  }

  void _updateAuthStatus(AuthStatus newStatus) {
    if (_currentStatus != newStatus) {
      _currentStatus = newStatus;
      _authStatusController.add(newStatus);
      notifyListeners(); // Notifier les listeners de ChangeNotifier
    }
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final authResponse = await remoteDataSource.login(email, password);
      await localDataSource.saveAccessToken(authResponse.accessToken);
      _updateAuthStatus(AuthStatus.authenticated);
      return UserEntity(id: authResponse.userId, email: authResponse.email);
    } on ServerException {
      _updateAuthStatus(AuthStatus.unauthenticated);
      rethrow; // Propage l'exception pour la gestion de l'UI
    } on CacheException {
      _updateAuthStatus(AuthStatus.unauthenticated);
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    final accessToken = await localDataSource.getAccessToken();
    if (accessToken != null) {
      await remoteDataSource.logout(accessToken);
    }
    await localDataSource.deleteAllTokens();
    _updateAuthStatus(AuthStatus.unauthenticated);
  }

  @override
  Future<String?> getAccessToken() async {
    return await localDataSource.getAccessToken();
  }

  @override
  Future<void> saveAccessToken(String token) async {
    await localDataSource.saveAccessToken(token);
    _updateAuthStatus(
      AuthStatus.authenticated,
    ); // Met à jour le statut après sauvegarde
  }

  @override
  void dispose() {
    _authStatusController.close();
    super.dispose();
  }

  @override
  Future<String?> getRefreshToken() {
    // TODO: implement getRefreshToken
    throw UnimplementedError();
  }

  @override
  Future<String?> refreshAccessToken() {
    // TODO: implement refreshAccessToken
    throw UnimplementedError();
  }

  @override
  Future<void> saveRefreshToken(String token) {
    // TODO: implement saveRefreshToken
    throw UnimplementedError();
  }

  @override
  AuthStatus get currentStatus => throw UnimplementedError();
}

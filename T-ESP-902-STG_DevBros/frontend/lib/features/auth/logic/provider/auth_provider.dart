import 'package:flutter/material.dart';
import 'package:inspiria/core/api/entity/user_entity.dart';
import 'package:inspiria/core/api/repository/auth_repository.dart';
import 'package:inspiria/core/api/repository/login_usecase.dart';
import 'package:inspiria/core/api/repository/logout_usecase.dart';
import 'package:inspiria/core/utils/constant/exceptions.dart';
import 'package:inspiria/main.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required AuthRepository authRepository,
    required Function(dynamic context) create,
    required MyApp child,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _authRepository = authRepository {
    
    _authRepository.authStatus.listen((status) {
      _status = status;
      if (status != AuthStatus.authenticated) {
        _currentUser = null;
        _accessToken = null;
      }
      notifyListeners();
    });

    _status = _authRepository.currentStatus;
    
    _initializeToken();
  }

  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final AuthRepository _authRepository;

  AuthStatus _status = AuthStatus.unknown;
  UserEntity? _currentUser;
  String? _accessToken;

  AuthStatus get status => _status;
  UserEntity? get currentUser => _currentUser;
  String? get accessToken => _accessToken;

  Future<void> _initializeToken() async {
    try {
      _accessToken = await _authRepository.getAccessToken();
      notifyListeners();
    } catch (_) {
      _accessToken = null;
    }
  }

  Future<void> login(String email, String password) async {
    _status = AuthStatus.unknown; 
    notifyListeners();
    try {
      final user = await _loginUseCase.call(email, password);
      _currentUser = user;
      _status = AuthStatus.authenticated;
      
      _accessToken = await _authRepository.getAccessToken();
      
      notifyListeners();
    } on ServerException catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      throw Exception('An unexpected error occurred during login: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _logoutUseCase.call();
    } finally {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _accessToken = null;
      notifyListeners();
    }
  }
}
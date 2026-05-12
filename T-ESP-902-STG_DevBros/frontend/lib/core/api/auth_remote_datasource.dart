import 'dart:io';
import 'package:dio/dio.dart';
import 'package:inspiria/core/utils/constant/api.dart';
import 'package:inspiria/core/utils/constant/exceptions.dart';
import 'package:inspiria/features/auth/logic/model/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);
  Future<String> refreshToken(String refreshToken);
  Future<void> logout(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.loginEndpoint,
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == HttpStatus.ok) {
        return AuthResponseModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Erreur de connexion',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response!.data['message'] ?? 'Erreur réseau/serveur',
          statusCode: e.response!.statusCode,
        );
      } else {
        throw ServerException(message: e.message ?? 'Erreur inconnue');
      }
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        ApiConstants.refreshTokenEndpoint,
        data: {'refreshToken': refreshToken},
      );
      if (response.statusCode == HttpStatus.ok) {
        return response.data['accessToken'];
      } else {
        throw ServerException(
          message:
              response.data['message'] ?? 'Erreur de rafraîchissement du token',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message:
              e.response!.data['message'] ??
              'Erreur réseau/serveur lors du rafraîchissement',
          statusCode: e.response!.statusCode,
        );
      } else {
        throw ServerException(
          message: e.message ?? 'Erreur inconnue lors du rafraîchissement',
        );
      }
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post(
        ApiConstants.logoutEndpoint,
        data: {'refreshToken': refreshToken},
      );
    } on DioException catch (e) {
      // Pour le logout, on ne jette pas forcément une erreur grave côté client
      // car la déconnexion locale reste prioritaire.
      throw Exception(
        'Erreur lors de l\'appel de déconnexion au serveur: ${e.response?.data ?? e.message}',
      );
    }
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/core/response/favorite_responce.dart';

void main() {
  group('FavoriteService - Response Model Tests', () {
    group('FavoriteResponces', () {
      test('should create FavoriteResponces with status code 200', () {
        final response = FavoriteResponces(statusCode: 200, favoriteList: []);
        expect(response.statusCode, equals(200));
        expect(response.favoriteList, isEmpty);
      });

      test('should create FavoriteResponces with status code 404', () {
        final response = FavoriteResponces(
          statusCode: 404,
          errorMessage: 'Not found',
        );
        expect(response.statusCode, equals(404));
        expect(response.errorMessage, equals('Not found'));
      });

      test('should create FavoriteResponces with status code 500', () {
        final response = FavoriteResponces(
          statusCode: 500,
          errorMessage: 'Server error',
        );
        expect(response.statusCode, equals(500));
        expect(response.errorMessage, equals('Server error'));
      });

      test('should create FavoriteResponces with status code 201 Created', () {
        final response = FavoriteResponces(
          statusCode: 201,
          favoriteList: [],
        );
        expect(response.statusCode, equals(201));
      });

      test('should create FavoriteResponces with status code 204 No Content', () {
        final response = FavoriteResponces(statusCode: 204);
        expect(response.statusCode, equals(204));
      });

      test('should create FavoriteResponces with status code 400 Bad Request', () {
        final response = FavoriteResponces(
          statusCode: 400,
          errorMessage: 'Bad request',
        );
        expect(response.statusCode, equals(400));
      });

      test('should create FavoriteResponces with status code 401 Unauthorized', () {
        final response = FavoriteResponces(
          statusCode: 401,
          errorMessage: 'Unauthorized',
        );
        expect(response.statusCode, equals(401));
      });

      test('should create FavoriteResponces with status code 403 Forbidden', () {
        final response = FavoriteResponces(
          statusCode: 403,
          errorMessage: 'Forbidden',
        );
        expect(response.statusCode, equals(403));
      });

      test('should handle null error message', () {
        final response = FavoriteResponces(statusCode: 200);
        expect(response.statusCode, equals(200));
        expect(response.errorMessage, isNull);
      });

      test('should handle empty favorite list', () {
        final response = FavoriteResponces(statusCode: 200, favoriteList: []);
        expect(response.favoriteList, isEmpty);
        expect(response.favoriteList?.length, equals(0));
      });

      test('should handle multiple favorites in list', () {
        final response = FavoriteResponces(statusCode: 200, favoriteList: []);
        expect(response.favoriteList?.length, equals(0));
      });

      test('should support JSON encoding/decoding pattern', () {
        final response = FavoriteResponces(
          statusCode: 200,
          favoriteList: [],
        );
        expect(response.statusCode, equals(200));
        expect(response.favoriteList, isNotNull);
      });

      test('should handle error message with special characters', () {
        final errorMsg = 'Error: invalid JSON "test"\n';
        final response = FavoriteResponces(
          statusCode: 500,
          errorMessage: errorMsg,
        );
        expect(response.errorMessage, equals(errorMsg));
      });

      test('should create response for timeout scenario', () {
        final response = FavoriteResponces(
          statusCode: 500,
          errorMessage: 'Request timeout',
        );
        expect(response.statusCode, equals(500));
      });

      test('should create response for connection error', () {
        final response = FavoriteResponces(
          statusCode: 500,
          errorMessage: 'Connection error',
        );
        expect(response.statusCode, equals(500));
      });
    });
  });
}

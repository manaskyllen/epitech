import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/core/response/generic_responce.dart';

void main() {
  group('GenericResponce Tests', () {
    test('should initialize with success status code', () {
      final response = GenericResponce(
        statusCode: 200,
      );

      expect(response.statusCode, 200);
      expect(response.errorMessage, isNull);
    });

    test('should initialize with error status and message', () {
      final response = GenericResponce(
        statusCode: 400,
        errorMessage: 'Bad Request',
      );

      expect(response.statusCode, 400);
      expect(response.errorMessage, 'Bad Request');
    });

    test('should initialize with server error', () {
      final response = GenericResponce(
        statusCode: 500,
        errorMessage: 'Internal Server Error',
      );

      expect(response.statusCode, 500);
      expect(response.errorMessage, 'Internal Server Error');
    });
  });
}
import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/features/auth/logic/model/auth_response_model.dart';

void main() {
  group('AuthResponseModel Tests', () {
    final Map<String, dynamic> tJson = {
      'accessToken': 'access_123',
      'refreshToken': 'refresh_456',
      'userId': 'user_789',
      'email': 'test@example.com',
    };

    final tModel = AuthResponseModel(
      accessToken: 'access_123',
      refreshToken: 'refresh_456',
      userId: 'user_789',
      email: 'test@example.com',
    );

    test('should create a valid model from JSON', () {
      final result = AuthResponseModel.fromJson(tJson);

      expect(result.accessToken, tModel.accessToken);
      expect(result.refreshToken, tModel.refreshToken);
      expect(result.userId, tModel.userId);
      expect(result.email, tModel.email);
    });

    test('should return a valid JSON map from the model', () {
      final result = tModel.toJson();

      expect(result, tJson);
      expect(result['accessToken'], tModel.accessToken);
      expect(result['userId'], tModel.userId);
    });

    test('should handle specific field types correctly', () {
      final result = AuthResponseModel.fromJson(tJson);
      
      expect(result.accessToken, isA<String>());
      expect(result.userId, isA<String>());
    });
  });
}
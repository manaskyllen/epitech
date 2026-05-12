import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/core/utils/constant/api.dart';

void main() {
  group('ApiConstants Tests', () {
    
    test('baseUrl should return the value from dotenv', () {
      dotenv.testLoad(fileInput: 'BASE_URL=https://api.inspiria.com');
      
      expect(ApiConstants.baseUrl, 'https://api.inspiria.com');
    });

    test('baseUrl should return empty string if BASE_URL is missing', () {
      dotenv.testLoad();
      
      expect(ApiConstants.baseUrl, '');
    });

    test('endpoints should have correct string values', () {
      expect(ApiConstants.loginEndpoint, '/login');
      expect(ApiConstants.registerEndpoint, '/register');
      expect(ApiConstants.minioUploadEndpoint, '/upload');
      expect(ApiConstants.convertImageEndpoint, '/convert-image-to-glb');
    });

    test('dynamic endpoints should contain placeholders', () {
      expect(ApiConstants.getUserByIdEndpoint, contains('{id}'));
      expect(ApiConstants.getSuitcaseByIdEndpoint, contains('{suitcaseId}'));
      expect(ApiConstants.getAddressByUserIdEndpoint, contains('{userId}'));
    });
    
    test('suitcase endpoints should be properly formatted', () {
      expect(ApiConstants.updateSuitcaseEndpoint, '/suitcase{suitcaseId}');
    });
  });
}
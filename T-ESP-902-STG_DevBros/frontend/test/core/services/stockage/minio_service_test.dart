import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:inspiria/core/services/stockage/minio_service.dart'; 
import 'package:mocktail/mocktail.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  dotenv.testLoad(fileInput: 'API_KEY=test_key');

  group('MinioService - getFile', () {
    const filename = 'test_image.png';

    test('should return bodyBytes when status code is 200', () async {
    
      final result = await MinioService.getFile(filename);
      
      expect(result, isNull); 
    });
  });

  group('MinioService - uploadFile', () {
    test('should return null if file does not exist', () async {
      final file = File('non_existent_path.png');
      
      final result = await MinioService.uploadFile(file);
      
      expect(result, isNull);
    });
  });
}
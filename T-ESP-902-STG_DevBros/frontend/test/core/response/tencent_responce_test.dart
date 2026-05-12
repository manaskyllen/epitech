import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/core/response/tencent_responce.dart';

void main() {
  group('TencentResponce Tests', () {
    test('should initialize with constructor', () {
      final response = TencentResponce(
        message: 'Success',
        modelPath: 'https://storage.com/model.glb',
      );

      expect(response.message, 'Success');
      expect(response.modelPath, 'https://storage.com/model.glb');
      expect(response.error, isNull);
    });

    test('should create instance from JSON with data', () {
      final json = {
        'message': 'Task completed',
        'data': 'path/to/model.glb',
        'error': null,
      };

      final response = TencentResponce.fromJson(json);

      expect(response.message, 'Task completed');
      expect(response.modelPath, 'path/to/model.glb');
      expect(response.error, isNull);
    });

    test('should create instance from JSON with error', () {
      final json = {
        'message': 'Failed',
        'data': null,
        'error': 'Service Unavailable',
      };

      final response = TencentResponce.fromJson(json);

      expect(response.message, 'Failed');
      expect(response.modelPath, isNull);
      expect(response.error, 'Service Unavailable');
    });

    test('should use default message if message is missing in JSON', () {
      final json = {
        'data': 'some_path',
      };

      final response = TencentResponce.fromJson(json);

      expect(response.message, 'Unknown status');
    });
  });
}
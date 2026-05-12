import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/core/model/suitcase_model.dart';
import 'package:inspiria/core/response/suitcase_responce.dart';

void main() {
  group('SuitcaseResponce Tests', () {
    test('should initialize with constructor', () {
      final mockSuitcase = SuitcaseModel(
        id: 1,
        name: 'Test Trip',
        destination: 'Paris',
        departure_date: DateTime.now(),
        end_date: DateTime.now().add(const Duration(days: 5)),
        user_id: 123,
      );

      final response = SuitcaseResponce(
        statusCode: 200,
        suitcase: mockSuitcase,
        warnings: {'items': 2},
        weather: {'temp': 20},
      );

      expect(response.statusCode, 200);
      expect(response.suitcase?.name, 'Test Trip');
      expect(response.warnings?['items'], 2);
    });

    test('should create instance from JSON', () {
      final json = {
        'statusCode': 201,
        'data': {
          'suitcase': {
            'id': 1,
            'name': 'Paris Trip',
            'destination': 'Paris',
            'departure_date': '2026-03-10T10:00:00Z',
            'end_date': '2026-03-15T10:00:00Z',
            'user_id': 123,
          },
          'warnings': {'socks': 1},
          'weather': {'condition': 'Sunny'}
        }
      };

      final response = SuitcaseResponce.fromJson(json);

      expect(response.statusCode, 201);
      expect(response.suitcase, isNotNull);
      expect(response.suitcase?.destination, 'Paris');
      expect(response.warnings?['socks'], 1);
    });

    test('should convert to JSON correctly', () {
      final response = SuitcaseResponce(
        statusCode: 200,
        warnings: {'test': 'warning'},
      );

      final json = response.toJson();

      expect(json['statusCode'], 200);
      expect(json['warnings'], {'test': 'warning'});
      expect(json['weather'], {}); // Test default value from your model
    });

    test('should initialize with error message', () {
      final response = SuitcaseResponce(
        statusCode: 500,
        errorMessage: 'Server Error',
      );

      expect(response.statusCode, 500);
      expect(response.errorMessage, 'Server Error');
      expect(response.suitcase, isNull);
    });
  });

  group('SuitcaseResponces (List) Tests', () {
    test('should initialize with a list of suitcases', () {
      final response = SuitcaseResponces(
        statusCode: 200,
        suitcaseList: [],
      );

      expect(response.statusCode, 200);
      expect(response.suitcaseList, isEmpty);
    });
  });
}
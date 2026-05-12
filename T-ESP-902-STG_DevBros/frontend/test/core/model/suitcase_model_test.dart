import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/core/model/suitcase_model.dart';

void main() {
  group('SuitcaseModel Tests', () {
    final mockJson = {
      'id': 1,
      'name': 'Summer Trip',
      'departure_date': '2026-06-01T10:00:00.000',
      'end_date': '2026-06-15T10:00:00.000',
      'destination': 'Ibiza',
      'user_id': 99,
      'clothings': [
        {'id': 1, 'name': 'T-shirt'}
      ],
      'created_at': '2026-01-01T08:00:00.000',
      'updated_at': '2026-01-02T08:00:00.000',
    };

    test('should create instance from full JSON', () {
      final model = SuitcaseModel.fromJson(mockJson);

      expect(model.id, 1);
      expect(model.name, 'Summer Trip');
      expect(model.destination, 'Ibiza');
      expect(model.user_id, 99);
      expect(model.departure_date, isA<DateTime>());
      expect(model.clothings?.length, 1);
      expect(model.createdAt, isNotNull);
    });

    test('should handle string-to-int conversion for IDs', () {
      final jsonWithStrings = {
        'id': '123',
        'user_id': '456',
        'name': 'String ID Test',
        'departure_date': '2026-03-13',
        'end_date': '2026-03-20',
        'destination': 'London',
      };

      final model = SuitcaseModel.fromJson(jsonWithStrings);

      expect(model.id, 123);
      expect(model.user_id, 456);
    });

    test('should provide default values for missing optional fields', () {
      final minimalJson = {
        'name': 'Quick Trip',
        'destination': 'Paris',
        'user_id': 1,
        // departure_date and end_date are missing
      };

      final model = SuitcaseModel.fromJson(minimalJson);

      expect(model.name, 'Quick Trip');
      expect(model.departure_date, isA<DateTime>()); // Should be DateTime.now()
      expect(model.clothings, isEmpty);
      expect(model.createdAt, isNull);
    });

    test('should convert instance to JSON correctly', () {
      final date = DateTime(2026, 3, 13);
      final model = SuitcaseModel(
        id: 50,
        name: 'Business',
        departure_date: date,
        end_date: date.add(const Duration(days: 2)),
        destination: 'Berlin',
        user_id: 10,
      );

      final json = model.toJson();

      expect(json['id'], 50);
      expect(json['departure_date'], date.toIso8601String());
      expect(json['destination'], 'Berlin');
      expect(json['clothings'], isA<List>());
    });

    test('round-trip conversion check', () {
      final model = SuitcaseModel.fromJson(mockJson);
      final json = model.toJson();
      final clone = SuitcaseModel.fromJson(json);

      expect(clone.name, model.name);
      expect(clone.destination, model.destination);
      expect(clone.user_id, model.user_id);
      expect(clone.departure_date.toIso8601String(), model.departure_date.toIso8601String());
    });
  });
}
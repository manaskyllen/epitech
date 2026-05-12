import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/core/model/address_model.dart';

void main() {
  group('AddressModel Tests', () {
    final mockAddressMap = {
      'id': 1,
      'street1': '123 Rue de la Paix',
      'street2': 'Bâtiment B',
      'city': 'Paris',
      'zipCode': '75000',
      'country': 'France',
      'user_id': 42,
    };

    test('should create an AddressModel instance from JSON', () {
      final address = AddressModel.fromJson(mockAddressMap);

      expect(address.id, 1);
      expect(address.street1, '123 Rue de la Paix');
      expect(address.city, 'Paris');
      expect(address.userId, 42);
    });

    test('should convert AddressModel instance to JSON map', () {
      final address = AddressModel(
        id: 1,
        street1: '123 Rue de la Paix',
        street2: 'Bâtiment B',
        city: 'Paris',
        zipCode: '75000',
        country: 'France',
        userId: 42,
      );

      final json = address.toJson();

      expect(json['id'], 1);
      expect(json['street1'], '123 Rue de la Paix');
      expect(json['user_id'], 42);
      expect(json.containsKey('zipCode'), true);
    });

    test('should maintain data integrity through round-trip conversion', () {
      final original = AddressModel.fromJson(mockAddressMap);
      final json = original.toJson();
      final clone = AddressModel.fromJson(json);

      expect(clone.id, original.id);
      expect(clone.street1, original.street1);
      expect(clone.userId, original.userId);
    });
  });
}
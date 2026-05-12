import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/core/model/address_model.dart';
import 'package:inspiria/core/response/address_responce.dart';

void main() {
  group('AddressResponce Tests', () {
    test('should initialize with single address and status code', () {
      final mockAddress = AddressModel(
        id: 1,
        street1: '123 Rue de Rivoli', 
        street2: 'Appartement 4B',     
        zipCode: '75001',             
        city: 'Paris',
        country: 'France',       
        userId: 42,                  
      );

      final response = AddressResponce(
        statusCode: 200,
        address: mockAddress,
      );

      expect(response.statusCode, 200);
      expect(response.address, mockAddress);
      expect(response.address?.city, 'Paris');
    });

    test('should initialize with error message', () {
      final response = AddressResponce(
        statusCode: 404,
        errorMessage: 'Address not found',
      );

      expect(response.statusCode, 404);
      expect(response.errorMessage, 'Address not found');
      expect(response.address, isNull);
    });
  });

  group('AddressResponces (List) Tests', () {
    test('should initialize with a list of addresses', () {
      final mockAddresses = [
        AddressModel(
          id: 1, 
          street1: 'Avenue A', 
          street2: '', 
          zipCode: '69000', 
          city: 'Lyon', 
          country: 'France', 
          userId: 42
        ),
        AddressModel(
          id: 2, 
          street1: 'Avenue B', 
          street2: '', 
          zipCode: '13000', 
          city: 'Marseille', 
          country: 'France', 
          userId: 42
        ),
      ];

      final response = AddressResponces(
        statusCode: 200,
        address: mockAddresses,
      );

      expect(response.statusCode, 200);
      expect(response.address?.length, 2);
    });
  });
}
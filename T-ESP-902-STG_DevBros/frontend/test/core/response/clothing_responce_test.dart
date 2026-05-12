import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/core/model/clothing_model.dart';
import 'package:inspiria/core/response/clothing_responce.dart';

void main() {
  group('ClothingResponce Tests', () {
    test('should initialize with a single clothing item and success status', () {
      final mockClothing = ClothingModel(
        id: 1,
        itemType: 'Top',
        color: 'Red',
        userId: 101,
      );

      final response = ClothingResponce(
        statusCode: 200,
        clothing: mockClothing,
      );

      expect(response.statusCode, 200);
      expect(response.clothing, mockClothing);
      expect(response.clothing?.itemType, 'Top');
      expect(response.errorMessage, isNull);
    });

    test('should initialize with an error message', () {
      final response = ClothingResponce(
        statusCode: 404,
        errorMessage: 'Not Found',
      );

      expect(response.statusCode, 404);
      expect(response.errorMessage, 'Not Found');
      expect(response.clothing, isNull);
    });
  });

  group('ClothingResponces (List) Tests', () {
    test('should initialize with a list of clothing items', () {
      final mockList = [
        ClothingModel(id: 1, itemType: 'Top', color: 'Blue'),
        ClothingModel(id: 2, itemType: 'Bottom', color: 'Black'),
      ];

      final response = ClothingResponces(
        statusCode: 200,
        clothingList: mockList,
      );

      expect(response.statusCode, 200);
      expect(response.clothingList?.length, 2);
      expect(response.clothingList![0].color, 'Blue');
      expect(response.clothingList![1].itemType, 'Bottom');
    });
  });
}
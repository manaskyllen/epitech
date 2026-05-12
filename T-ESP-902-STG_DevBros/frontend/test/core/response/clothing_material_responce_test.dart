import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/core/model/clothing_material_model.dart';
import 'package:inspiria/core/response/clothing_material_responce.dart';

void main() {
  group('ClothingMaterialResponce Tests', () {
    test('should initialize with a single material and success status', () {
      final mockMaterial = ClothingMaterialModel(
        id: 1,
        name: 'Cotton Soft',
        material: '100% Cotton', 
        model: 'Standard-V1',
      );

      final response = ClothingMaterialResponce(
        statusCode: 200,
        clothingMaterial: mockMaterial,
      );

      expect(response.statusCode, 200);
      expect(response.clothingMaterial, mockMaterial);
      expect(response.clothingMaterial?.name, 'Cotton Soft');
      expect(response.errorMessage, isNull);
    });

    test('should initialize with an error message', () {
      final response = ClothingMaterialResponce(
        statusCode: 500,
        errorMessage: 'Internal Server Error',
      );

      expect(response.statusCode, 500);
      expect(response.errorMessage, 'Internal Server Error');
      expect(response.clothingMaterial, isNull);
    });
  });

  group('ClothingMaterialResponces (List) Tests', () {
    test('should initialize with a list of materials', () {
      final mockList = [
        ClothingMaterialModel(
          id: 1, 
          name: 'Silk Premium', 
          material: 'Silk', 
          model: 'Luxury-A'
        ),
        ClothingMaterialModel(
          id: 2, 
          name: 'Wool Warm', 
          material: 'Sheep Wool', 
          model: 'Winter-B'
        ),
      ];

      final response = ClothingMaterialResponces(
        statusCode: 200,
        clothingMaterials: mockList,
      );

      expect(response.statusCode, 200);
      expect(response.clothingMaterials?.length, 2);
      expect(response.clothingMaterials![0].name, 'Silk Premium');
    });
  });
}
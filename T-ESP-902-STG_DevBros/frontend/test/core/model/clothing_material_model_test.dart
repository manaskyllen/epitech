import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/core/model/clothing_material_model.dart';

void main() {
  group('ClothingMaterialModel Tests', () {
    final mockJson = {
      'id': 1,
      'name': 'Cotton Soft',
      'material': '100% Cotton',
      'model': 'V1-Standard',
    };

    test('should create a ClothingMaterialModel instance from JSON', () {
      final materialModel = ClothingMaterialModel.fromJson(mockJson);

      expect(materialModel.id, 1);
      expect(materialModel.name, 'Cotton Soft');
      expect(materialModel.material, '100% Cotton');
      expect(materialModel.model, 'V1-Standard');
    });

    test('should convert ClothingMaterialModel instance to JSON map', () {
      final materialModel = ClothingMaterialModel(
        id: 1,
        name: 'Cotton Soft',
        material: '100% Cotton',
        model: 'V1-Standard',
      );

      final json = materialModel.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Cotton Soft');
      expect(json['material'], '100% Cotton');
      expect(json['model'], 'V1-Standard');
    });

    test('should maintain data integrity during conversion round-trip', () {
      final original = ClothingMaterialModel.fromJson(mockJson);
      final json = original.toJson();
      final clone = ClothingMaterialModel.fromJson(json);

      expect(clone.id, original.id);
      expect(clone.name, original.name);
      expect(clone.material, original.material);
      expect(clone.model, original.model);
    });
  });
}
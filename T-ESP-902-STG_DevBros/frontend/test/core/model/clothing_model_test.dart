import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/core/model/clothing_model.dart';

void main() {
  group('ClothingModel Tests', () {
    test('should create instance from full JSON', () {
      final json = {
        'id': 10,
        'itemType': 'Top',
        'itemSubtype': 'T-shirt',
        'color': 'White',
        'size': 'L',
        'style': 'Casual',
        'season': 'Summer',
        'gender': 'Unisex',
        'fabric': 'Cotton',
        'texture': 'Soft',
        'user_id': 1,
        'clothingModel_id': 5,
        'imageName': 'white_tshirt.png'
      };

      final model = ClothingModel.fromJson(json);

      expect(model.id, 10);
      expect(model.itemType, 'Top');
      expect(model.color, 'White');
      expect(model.userId, 1);
      expect(model.imageName, 'white_tshirt.png');
    });

    test('should handle imageName priority from different JSON keys', () {
      final jsonFilename = {'filename': 'test_image.jpg'};
      final jsonImageUrl = {'image_url': 'http://link.com/image.png'};

      final modelFromFilename = ClothingModel.fromJson(jsonFilename);
      final modelFromUrl = ClothingModel.fromJson(jsonImageUrl);

      expect(modelFromFilename.imageName, 'test_image.jpg');
      expect(modelFromUrl.imageName, 'http://link.com/image.png');
    });

    test('should handle null values in JSON gracefully', () {
      final json = {'id': 1};
      final model = ClothingModel.fromJson(json);

      expect(model.id, 1);
      expect(model.itemType, isNull);
      expect(model.imageName, isNull);
    });

    test('should convert instance to JSON correctly', () {
      final model = ClothingModel(
        id: 99,
        itemType: 'Pants',
        userId: 7,
      );

      final json = model.toJson();

      expect(json['id'], 99);
      expect(json['itemType'], 'Pants');
      expect(json['user_id'], 7);
      expect(json['color'], isNull);
    });

    test('round-trip conversion check', () {
      final original = ClothingModel(id: 1, itemType: 'Dress', color: 'Red');
      final json = original.toJson();
      final clone = ClothingModel.fromJson(json);

      expect(clone.id, original.id);
      expect(clone.itemType, original.itemType);
      expect(clone.color, original.color);
    });
  });
}
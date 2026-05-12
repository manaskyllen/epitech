import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/core/model/favorite_model.dart';

void main() {
  group('FavoriteModel Tests', () {
    final mockJson = {
      'id': 1,
      'user_id': 100,
      'clothing_id': 50,
      'outfit_id': 0,
    };

    test('should create a FavoriteModel instance from JSON', () {
      final model = FavoriteModel.fromJson(mockJson);

      expect(model.id, 1);
      expect(model.userId, 100);
      expect(model.clothingId, 50);
      expect(model.outfitId, 0);
    });

    test('should convert FavoriteModel instance to JSON map', () {
      final model = FavoriteModel(
        id: 1,
        userId: 100,
        clothingId: 50,
        outfitId: 0,
      );

      final json = model.toJson();

      expect(json['id'], 1);
      expect(json['user_id'], 100);
      expect(json['clothing_id'], 50);
      expect(json['outfit_id'], 0);
    });

    test('should maintain data integrity through round-trip conversion', () {
      final original = FavoriteModel.fromJson(mockJson);
      final json = original.toJson();
      final clone = FavoriteModel.fromJson(json);

      expect(clone.id, original.id);
      expect(clone.userId, original.userId);
      expect(clone.clothingId, original.clothingId);
      expect(clone.outfitId, original.outfitId);
    });
  });
}
import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/core/model/favorite_model.dart';
import 'package:inspiria/core/response/favorite_responce.dart';

void main() {
  group('FavoriteResponce Tests', () {
    test('should initialize with a single favorite and success status', () {
      final mockFavorite = FavoriteModel(
        id: 1,
        userId: 10,
        clothingId: 5,
        outfitId: 0,
      );

      final response = FavoriteResponce(
        statusCode: 200,
        favorite: mockFavorite,
      );

      expect(response.statusCode, 200);
      expect(response.favorite, mockFavorite);
      expect(response.favorite?.id, 1);
      expect(response.errorMessage, isNull);
    });

    test('should initialize with an error message', () {
      final response = FavoriteResponce(
        statusCode: 400,
        errorMessage: 'Favorite not found',
      );

      expect(response.statusCode, 400);
      expect(response.errorMessage, 'Favorite not found');
      expect(response.favorite, isNull);
    });
  });

  group('FavoriteResponces (List) Tests', () {
    test('should initialize with a list of favorites', () {
      final mockList = [
        FavoriteModel(id: 1, userId: 10, clothingId: 5, outfitId: 0),
        FavoriteModel(id: 2, userId: 10, clothingId: 0, outfitId: 12),
      ];

      final response = FavoriteResponces(
        statusCode: 200,
        favoriteList: mockList,
      );

      expect(response.statusCode, 200);
      expect(response.favoriteList?.length, 2);
      expect(response.favoriteList![0].id, 1);
    });
  });
}
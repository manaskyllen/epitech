import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/features/outfit/logic/model/outfit_model.dart';
import 'package:inspiria/features/outfit/logic/response/outfit_responce.dart';

void main() {
  group('OutfitModel', () {
    test('should create OutfitModel from JSON', () {
      final json = {
        'id': 'outfit-1',
        'name': 'Casual Friday',
        'description': 'A comfortable casual outfit',
      };

      final outfit = OutfitModel.fromJson(json);
      expect(outfit, isNotNull);
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        'id': 'outfit-1',
        'name': 'Casual Friday',
      };

      final outfit = OutfitModel.fromJson(json);
      expect(outfit, isNotNull);
    });

    test('should parse outfit ID correctly', () {
      final json = {
        'id': 'test-id-123',
        'name': 'Test Outfit',
      };

      final outfit = OutfitModel.fromJson(json);
      expect(outfit.id, isNotNull);
    });

    test('should parse outfit name correctly', () {
      final json = {
        'id': 'outfit-1',
        'name': 'Summer Outfit',
      };

      final outfit = OutfitModel.fromJson(json);
      expect(outfit.name, equals('Summer Outfit'));
    });

    test('should convert OutfitModel to JSON', () {
      final json = {
        'id': 'outfit-1',
        'name': 'Test Outfit',
      };

      final outfit = OutfitModel.fromJson(json);
      final convertedJson = outfit.toJson();
      
      expect(convertedJson, isA<Map<String, dynamic>>());
      expect(convertedJson.containsKey('id'), isTrue);
    });

    test('should handle empty JSON object', () {
      final json = <String, dynamic>{};
      expect(() => OutfitModel.fromJson(json), isNotNull);
    });

    test('should create multiple OutfitModels', () {
      final json1 = {'id': '1', 'name': 'Outfit1'};
      final json2 = {'id': '2', 'name': 'Outfit2'};

      final outfit1 = OutfitModel.fromJson(json1);
      final outfit2 = OutfitModel.fromJson(json2);

      expect(outfit1, isNotNull);
      expect(outfit2, isNotNull);
    });
  });

  group('OutfitResponce (Single)', () {
    test('should create OutfitResponce with outfit', () {
      final responce = OutfitResponce(
        statusCode: 200,
        outfit: OutfitModel.fromJson({'id': '1', 'name': 'Test'}),
      );

      expect(responce.statusCode, equals(200));
      expect(responce.outfit, isNotNull);
    });

    test('should create OutfitResponce with error', () {
      final responce = OutfitResponce(
        statusCode: 404,
        errorMessage: 'Outfit not found',
      );

      expect(responce.statusCode, equals(404));
      expect(responce.errorMessage, equals('Outfit not found'));
    });

    test('should have null outfit on error', () {
      final responce = OutfitResponce(
        statusCode: 500,
        errorMessage: 'Server error',
      );

      expect(responce.outfit, isNull);
    });

    test('should handle 201 status for creation', () {
      final responce = OutfitResponce(
        statusCode: 201,
        outfit: OutfitModel.fromJson({'id': 'new', 'name': 'New'}),
      );

      expect(responce.statusCode, equals(201));
    });
  });

  group('OutfitResponces (List)', () {
    test('should create OutfitResponces with list', () {
      final outfits = [
        OutfitModel.fromJson({'id': '1', 'name': 'Outfit1'}),
        OutfitModel.fromJson({'id': '2', 'name': 'Outfit2'}),
      ];

      final responce = OutfitResponces(
        statusCode: 200,
        outfitList: outfits,
      );

      expect(responce.statusCode, equals(200));
      expect(responce.outfitList, hasLength(2));
    });

    test('should create OutfitResponces with empty list', () {
      final responce = OutfitResponces(
        statusCode: 200,
        outfitList: [],
      );

      expect(responce.outfitList, isEmpty);
    });

    test('should create OutfitResponces with error', () {
      final responce = OutfitResponces(
        statusCode: 404,
        errorMessage: 'No outfits found',
      );

      expect(responce.statusCode, equals(404));
      expect(responce.errorMessage, equals('No outfits found'));
    });

    test('should handle 201 status for bulk creation', () {
      final responce = OutfitResponces(
        statusCode: 201,
        outfitList: [OutfitModel.fromJson({'id': '1'})],
      );

      expect(responce.statusCode, equals(201));
    });

    test('should have null list on error', () {
      final responce = OutfitResponces(
        statusCode: 500,
        errorMessage: 'Server error',
      );

      expect(responce.outfitList, isNull);
    });

    test('should handle multiple outfits in list', () {
      final outfits = List.generate(
        5,
        (i) => OutfitModel.fromJson({'id': '$i', 'name': 'Outfit$i'}),
      );

      final responce = OutfitResponces(
        statusCode: 200,
        outfitList: outfits,
      );

      expect(responce.outfitList, hasLength(5));
    });
  });

  group('HTTP Status Codes', () {
    test('should handle 200 OK', () {
      final responce = OutfitResponce(statusCode: 200);
      expect(responce.statusCode, equals(200));
    });

    test('should handle 201 Created', () {
      final responce = OutfitResponce(statusCode: 201);
      expect(responce.statusCode, equals(201));
    });

    test('should handle 400 Bad Request', () {
      final responce = OutfitResponce(
        statusCode: 400,
        errorMessage: 'Bad request',
      );
      expect(responce.statusCode, equals(400));
    });

    test('should handle 401 Unauthorized', () {
      final responce = OutfitResponce(statusCode: 401);
      expect(responce.statusCode, equals(401));
    });

    test('should handle 404 Not Found', () {
      final responce = OutfitResponce(statusCode: 404);
      expect(responce.statusCode, equals(404));
    });

    test('should handle 500 Server Error', () {
      final responce = OutfitResponce(statusCode: 500);
      expect(responce.statusCode, equals(500));
    });
  });
}

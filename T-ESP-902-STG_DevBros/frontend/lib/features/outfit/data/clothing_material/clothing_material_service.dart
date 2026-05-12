import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inspiria/core/api/token_storage.dart';
import 'package:inspiria/core/model/clothing_material_model.dart';
import 'package:inspiria/core/response/clothing_material_responce.dart';
import 'package:inspiria/core/utils/constant/api.dart';

class ClothingmaterialService {
  static http.Client client = http.Client();
  static Future<ClothingMaterialResponces?> getAllClothingMaterial() async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getAllClothingModelEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return ClothingMaterialResponces(
          statusCode: response.statusCode,
          clothingMaterials: jsonList.map((json) => ClothingMaterialModel.fromJson(json)).toList(),
        );
      } else if (response.statusCode == 404) {
        return ClothingMaterialResponces(
          statusCode: response.statusCode,
          errorMessage: 'Clothing materials not found',
        );
      } else {
        return ClothingMaterialResponces(
          statusCode: response.statusCode,
          errorMessage: 'Failed to load clothing materials',
        );
      }
    } catch (e) {
      return ClothingMaterialResponces(
        statusCode: 500,
        errorMessage: e.toString(),
      );
    }
  }

  static Future<ClothingMaterialResponce?> getClothingMaterialById(String id) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getClothingModelByIdEndpoint.replaceFirst("{id}", id)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        return ClothingMaterialResponce(
          statusCode: response.statusCode,
          clothingMaterial: ClothingMaterialModel.fromJson(jsonMap),
        );
      } else if (response.statusCode == 404) {
        return ClothingMaterialResponce(
          statusCode: response.statusCode,
          errorMessage: 'Clothing material not found',
        );
      } else {
        return ClothingMaterialResponce(
          statusCode: response.statusCode,
          errorMessage: 'Failed to load clothing material',
        );
      }
    } catch (e) {
      return ClothingMaterialResponce(
        statusCode: 500,
        errorMessage: e.toString(),
      );
    }
  }

  static Future<ClothingMaterialResponce?> createClothingMaterial(ClothingMaterialModel clothingMaterial) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createClothingModelEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(clothingMaterial.toJson()),
      );

      if (response.statusCode == 201) {
        return ClothingMaterialResponce(
          statusCode: response.statusCode,
          clothingMaterial: ClothingMaterialModel.fromJson(json.decode(response.body)),
        );
      } else {
        return ClothingMaterialResponce(
          statusCode: response.statusCode,
          errorMessage: 'Failed to create clothing material',
        );
      }
    } catch (e) {
      return ClothingMaterialResponce(
        statusCode: 500,
        errorMessage: e.toString(),
      );
    }
  }

  static Future<ClothingMaterialResponce?> updateClothingMaterial(String id, ClothingMaterialModel clothingMaterial) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await client.put(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updateClothingModelEndpoint.replaceFirst("{id}", id)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(clothingMaterial.toJson()),
      );

      if (response.statusCode == 200) {
        return ClothingMaterialResponce(
          statusCode: response.statusCode,
          clothingMaterial: ClothingMaterialModel.fromJson(json.decode(response.body)),
        );
      } else if (response.statusCode == 404) {
        return ClothingMaterialResponce(
          statusCode: response.statusCode,
          errorMessage: 'Clothing material not found',
        );
      } else {
        return ClothingMaterialResponce(
          statusCode: response.statusCode,
          errorMessage: 'Failed to update clothing material',
        );
      }
    } catch (e) {
      return ClothingMaterialResponce(
        statusCode: 500,
        errorMessage: e.toString(),
      );
    }
  }

  static Future<bool> deleteClothingMaterial(String id) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.deleteClothingModelEndpoint.replaceFirst("{id}", id)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Clothing material not found');
      } else {
        throw Exception('Failed to delete clothing material');
      }
    } catch (e) {
      return false;
    }
  }
}
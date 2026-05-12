import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inspiria/core/api/token_storage.dart';
import 'package:inspiria/core/utils/constant/api.dart';
import 'package:inspiria/features/outfit/logic/model/outfit_item_model.dart';
import 'package:inspiria/features/outfit/logic/response/outfit_item_responce.dart';

class OutfititemService {
  static Future<OutfitItemResponce?> createOutfitItem(Map<String, dynamic> outfitItemData) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createOutfitItemEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(outfitItemData),
      );

      if (response.statusCode == 201) {
        return OutfitItemResponce(statusCode: response.statusCode, outfitItem: OutfitItemModel.fromJson(json.decode(response.body)));
      } else {
        return OutfitItemResponce(statusCode: response.statusCode, errorMessage: 'Failed to create outfit item');
      }
    } catch (e) {
      return OutfitItemResponce(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<bool> deleteOutfitItem(String id) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.deleteOutfitItemEndpoint.replaceFirst("{id}", id)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Outfit item not found');
      } else {
        throw Exception('Failed to delete outfit item');
      }
    } catch (e) {
      return false;
    }
  }
}
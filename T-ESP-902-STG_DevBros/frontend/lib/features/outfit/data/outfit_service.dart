import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inspiria/core/api/token_storage.dart';
import 'package:inspiria/core/utils/constant/api.dart';
import 'package:inspiria/features/outfit/logic/model/outfit_model.dart';
import 'package:inspiria/features/outfit/logic/response/outfit_responce.dart';

class OutfitService {
  static Future<OutfitResponces?> getAllOutfit() async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getAllOutfitEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return OutfitResponces(statusCode: response.statusCode, outfitList: jsonList.map((json) => OutfitModel.fromJson(json)).toList());
      } else if (response.statusCode == 404) {
        return OutfitResponces(statusCode: response.statusCode, errorMessage: 'Outfits not found');
      } else {
        return OutfitResponces(statusCode: response.statusCode, errorMessage: 'Failed to load outfits');
      }
    } catch (e) {
      return OutfitResponces(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<OutfitResponce?> getOutfitById(String id) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getOutfitByIdEndpoint.replaceFirst("{id}", id)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return OutfitResponce(statusCode: response.statusCode, outfit: OutfitModel.fromJson(json.decode(response.body)));
      } else if (response.statusCode == 404) {
        return OutfitResponce(statusCode: response.statusCode, errorMessage: 'Outfit not found');
      } else {
        return OutfitResponce(statusCode: response.statusCode, errorMessage: 'Failed to load outfit');
      }
    } catch (e) {
      return OutfitResponce(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<OutfitResponces?> getOutfitByUserId(String userId) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getOutfitByUserIdEndpoint.replaceFirst("{userId}", userId)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return OutfitResponces(statusCode: response.statusCode, outfitList: jsonList.map((json) => OutfitModel.fromJson(json)).toList());
      } else if (response.statusCode == 404) {
        return OutfitResponces(statusCode: response.statusCode, errorMessage: 'Outfits not found for user');
      } else {
        return OutfitResponces(statusCode: response.statusCode, errorMessage: 'Failed to load outfits for user');
      }
    } catch (e) {
      return OutfitResponces(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<OutfitResponce?> createOutfit(Map<String, dynamic> outfitData) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createOutfitEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(outfitData),
      );

      if (response.statusCode == 201) {
        return OutfitResponce(statusCode: response.statusCode, outfit: OutfitModel.fromJson(json.decode(response.body)));
      } else {
        return OutfitResponce(statusCode: response.statusCode, errorMessage: 'Failed to create outfit');
      }
    } catch (e) {
      return OutfitResponce(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<bool> deleteOutfit(String id) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.deleteOutfitEndpoint.replaceFirst("{id}", id)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Outfit not found');
      } else {
        throw Exception('Failed to delete outfit');
      }
    } catch (e) {
      return false;
    }
  }

  static Future<OutfitResponce?> updateOutfit(String id, Map<String, dynamic> outfitData) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updateOutfitEndpoint.replaceFirst("{id}", id)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(outfitData),
      );

      if (response.statusCode == 200) {
        return OutfitResponce(statusCode: response.statusCode, outfit: OutfitModel.fromJson(json.decode(response.body)));   
      } else if (response.statusCode == 404) {
        return OutfitResponce(statusCode: response.statusCode, errorMessage: 'Outfit not found');
      } else {
        return OutfitResponce(statusCode: response.statusCode, errorMessage: 'Failed to update outfit');
      }
    } catch (e) {
      return OutfitResponce(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<OutfitResponces?> getClothingByOutfitId(String id) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getClothingByOutfitIdEndpoint.replaceFirst("{id}", id)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return OutfitResponces(statusCode: response.statusCode, outfitList: jsonList.map((json) => OutfitModel.fromJson(json)).toList());
      } else if (response.statusCode == 404) {
        return OutfitResponces(statusCode: response.statusCode, errorMessage: 'Clothing not found for this outfit');
      } else {
        return OutfitResponces(statusCode: response.statusCode, errorMessage: 'Failed to load clothing for this outfit');
      }
    } catch (e) {
      return OutfitResponces(statusCode: 500, errorMessage: e.toString());
    }
  }
}
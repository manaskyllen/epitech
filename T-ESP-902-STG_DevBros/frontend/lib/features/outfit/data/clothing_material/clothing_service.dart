import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:inspiria/core/api/token_storage.dart';
import 'package:inspiria/core/model/clothing_model.dart';
import 'package:inspiria/core/response/clothing_responce.dart';
import 'package:inspiria/core/utils/constant/api.dart';

class ClothingService {

  static Future<ClothingResponces?> getAllClothing() async {
    try {
      final token = await TokenStorage().getAccessToken();
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getAllClothingEndpoint}');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        return ClothingResponces(
          statusCode: response.statusCode, 
          clothingList: jsonList.map((json) => ClothingModel.fromJson(json)).toList()
        );
      } else if (response.statusCode == 404) {
        return ClothingResponces(statusCode: response.statusCode, errorMessage: 'No clothing found');
      } else {
        return ClothingResponces(statusCode: response.statusCode, errorMessage: 'Failed to load clothing');
      }
    } catch (e) {
      return ClothingResponces(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<ClothingResponce?> getClothingById(String id) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getClothingByIdEndpoint.replaceFirst("{id}", id)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(response.body);

        return ClothingResponce(statusCode: response.statusCode, clothing: ClothingModel.fromJson(jsonMap));
      } else if (response.statusCode == 404) {
        return ClothingResponce(statusCode: response.statusCode, errorMessage: 'Clothing not found');
      } else {
        return ClothingResponce(statusCode: response.statusCode, errorMessage: 'Failed to load clothing');
      }
    } catch (e) {
      return ClothingResponce(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<ClothingResponce?> createClothing(ClothingModel clothing) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createClothingEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(clothing.toJson()),
      );

      if (response.statusCode == 201) {
        return ClothingResponce(statusCode: response.statusCode, clothing: ClothingModel.fromJson(json.decode(response.body)));
      } else {
        return ClothingResponce(statusCode: response.statusCode, errorMessage: 'Failed to create clothing');
      }
    } catch (e) {
      return ClothingResponce(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<ClothingResponce?> updateClothing(String id, ClothingModel clothing) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updateClothingEndpoint.replaceFirst("{id}", id)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(clothing.toJson()),
      );

      if (response.statusCode == 200) {
        return ClothingResponce(statusCode: response.statusCode, clothing: ClothingModel.fromJson(json.decode(response.body)));
      } else if (response.statusCode == 404) {
        return ClothingResponce(statusCode: response.statusCode, errorMessage: 'Clothing not found');
      } else {
        return ClothingResponce(statusCode: response.statusCode, errorMessage: 'Failed to update clothing');
      }
    } catch (e) {
      return ClothingResponce(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<bool> deleteClothing(String id) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.deleteClothingEndpoint.replaceFirst("{id}", id)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Clothing not found');
      } else {
        throw Exception('Failed to delete clothing');
      }
    } catch (e) {
      return false;
    }
  }

  static Future<ClothingResponces?> getClothingByUserId(String userId) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getClothingByUserIdEndpoint.replaceFirst("{userId}", userId)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        
        return ClothingResponces(statusCode: response.statusCode, clothingList: jsonList.map((json) => ClothingModel.fromJson(json)).toList());
      } else if (response.statusCode == 404) {
        return ClothingResponces(statusCode: response.statusCode, errorMessage: 'Clothing not found for user');
      } else {
        return ClothingResponces(statusCode: response.statusCode, errorMessage: 'Failed to load clothing for user');
      }
    } catch (e) {
      return ClothingResponces(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<Map<String, dynamic>?> analyzeClothingIA(File imageFile) async {
      try {
        final token = await TokenStorage().getAccessToken();
        
        final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.analyzeClothingEndpoint}');

        final request = http.MultipartRequest('POST', url);
        request.headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        });
        
        request.files.add(await http.MultipartFile.fromPath(
          'file', 
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ));

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          debugPrint('Échec de l\'analyse IA. Status: ${response.statusCode}');
          return null;
        }
      } catch (e) {
        debugPrint('ERREUR IA: $e');
        return null;
      }
    }

    static Future<bool> storeClothingFinal(Map<String, dynamic> data, File imageFile) async {
    try {
      final token = await TokenStorage().getAccessToken();
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createClothingEndpoint}');

      final request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Exception storeClothingFinal: $e');
      return false;
    }
  }
}
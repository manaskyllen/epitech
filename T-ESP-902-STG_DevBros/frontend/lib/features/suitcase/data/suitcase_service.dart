import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:inspiria/core/api/token_storage.dart';
import 'package:inspiria/core/model/suitcase_model.dart';
import 'package:inspiria/core/response/suitcase_responce.dart';
import 'package:inspiria/core/utils/constant/api.dart';

class SuitcaseService {
  static http.Client client = http.Client();

  @visibleForTesting
  static String? mockToken;

  @visibleForTesting
  static String? mockBaseUrl;

  /// Helper pour obtenir l'URL de base sans déclencher d'erreur d'initialisation en test
  static String _getBaseUrl() => mockBaseUrl ?? ApiConstants.baseUrl;

  static Future<SuitcaseResponces?> getAllSuitcaseByUserId(String userId) async {
    try {
      final token = mockToken ?? await TokenStorage().getAccessToken();
      final url = '${_getBaseUrl()}${ApiConstants.getAllUserSuitcasesEndpoint.replaceFirst("{userId}", userId)}';

      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);
        List<dynamic> jsonList;

        if (jsonResponse is Map && jsonResponse.containsKey('suitcases')) {
          jsonList = jsonResponse['suitcases'];
        } else if (jsonResponse is List) {
          jsonList = jsonResponse;
        } else {
          jsonList = [];
        }

        return SuitcaseResponces(
            statusCode: response.statusCode,
            suitcaseList: jsonList.map((json) => SuitcaseModel.fromJson(json)).toList()
        );
      } else if (response.statusCode == 404) {
        return SuitcaseResponces(statusCode: response.statusCode, errorMessage: 'No suitcase(s) found');
      } else {
        return SuitcaseResponces(statusCode: response.statusCode, errorMessage: 'Failed to load suitcase(s)');
      }
    } catch (e) {
      return SuitcaseResponces(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<SuitcaseResponce?> createSuitcase(SuitcaseModel suitcase) async {
    try {
      final token = mockToken ?? await TokenStorage().getAccessToken();
      final url = '${_getBaseUrl()}${ApiConstants.createSuitcaseEndpoint}';

      final response = await client.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(suitcase.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        return SuitcaseResponce(
          statusCode: response.statusCode,
          suitcase: SuitcaseModel.fromJson(jsonResponse['suitcase']),
          warnings: jsonResponse['warnings'],
          weather: jsonResponse['weather'],
        );
      } else {
        return SuitcaseResponce(statusCode: response.statusCode, errorMessage: 'Failed to create suitcase');
      }
    } catch (e) {
      return SuitcaseResponce(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<SuitcaseResponce?> getSuitcaseById(String suitcaseId) async {
    try {
      final token = mockToken ?? await TokenStorage().getAccessToken();
      final url = '${_getBaseUrl()}${ApiConstants.getClothingByIdEndpoint.replaceFirst("{suitcaseId}", suitcaseId)}';

      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final suitcaseData = jsonResponse.containsKey('suitcase') ? jsonResponse['suitcase'] : jsonResponse;

        return SuitcaseResponce(
            statusCode: response.statusCode,
            suitcase: SuitcaseModel.fromJson(suitcaseData)
        );
      } else if (response.statusCode == 404) {
        return SuitcaseResponce(statusCode: response.statusCode, errorMessage: 'Suitcase not found');
      } else {
        return SuitcaseResponce(statusCode: response.statusCode, errorMessage: 'Failed to load suitcase');
      }
    } catch (e) {
      return SuitcaseResponce(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<SuitcaseResponce?> updateSuitcase(String suitcaseId, SuitcaseModel suitcase) async {
    try {
      final token = mockToken ?? await TokenStorage().getAccessToken();
      final url = '${_getBaseUrl()}${ApiConstants.updateSuitcaseEndpoint.replaceFirst("{suitcaseId}", suitcaseId)}';

      final response = await client.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(suitcase.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final suitcaseData = jsonResponse.containsKey('suitcase') ? jsonResponse['suitcase'] : jsonResponse;

        return SuitcaseResponce(
            statusCode: response.statusCode,
            suitcase: SuitcaseModel.fromJson(suitcaseData)
        );
      } else if (response.statusCode == 404) {
        return SuitcaseResponce(statusCode: response.statusCode, errorMessage: 'Suitcase not found');
      } else {
        return SuitcaseResponce(statusCode: response.statusCode, errorMessage: 'Failed to update suitcase');
      }
    } catch (e) {
      return SuitcaseResponce(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<bool> deleteSuitcase(String suitcaseId) async {
    try {
      final token = mockToken ?? await TokenStorage().getAccessToken();
      final url = '${_getBaseUrl()}${ApiConstants.deleteSuitcaseEndpoint.replaceFirst("{suitcaseId}", suitcaseId)}';

      final response = await client.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return (response.statusCode == 200 || response.statusCode == 204);
    } catch (e) {
      debugPrint('🗑️ Erreur Exception : $e');
      return false;
    }
  }

  static Future<SuitcaseResponce?> addClothingIntoSuitcase(String suitcaseId, String clothingId) async {
    try {
      final token = mockToken ?? await TokenStorage().getAccessToken();
      final url = '${_getBaseUrl()}${ApiConstants.addClothingIntoSuitcaseEndpoint.replaceFirst("{suitcaseId}", suitcaseId)}';

      final response = await client.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'clothing_id': clothingId}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final suitcaseData = jsonResponse.containsKey('suitcase') ? jsonResponse['suitcase'] : jsonResponse;

        return SuitcaseResponce(statusCode: response.statusCode, suitcase: SuitcaseModel.fromJson(suitcaseData));
      } else {
        return SuitcaseResponce(statusCode: response.statusCode, errorMessage: 'Failed to add clothing into suitcase');
      }
    } catch (e) {
      return SuitcaseResponce(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<SuitcaseResponce?> removeClothingFromSuitcase(String suitcaseId, String clothingId) async {
    try {
      final token = mockToken ?? await TokenStorage().getAccessToken();
      final url = '${_getBaseUrl()}${ApiConstants.removeClothingFromSuitcaseEndpoint.replaceFirst("{suitcaseId}", suitcaseId)}';

      final response = await client.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'clothing_id': clothingId}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final suitcaseData = jsonResponse.containsKey('suitcase') ? jsonResponse['suitcase'] : jsonResponse;

        return SuitcaseResponce(statusCode: response.statusCode, suitcase: SuitcaseModel.fromJson(suitcaseData));
      } else {
        return SuitcaseResponce(statusCode: response.statusCode, errorMessage: 'Failed to remove clothing from suitcase');
      }
    } catch (e) {
      return SuitcaseResponce(statusCode: 500, errorMessage: e.toString());
    }
  }
}
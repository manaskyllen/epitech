import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inspiria/core/api/token_storage.dart';
import 'package:inspiria/core/model/favorite_model.dart';
import 'package:inspiria/core/response/favorite_responce.dart';
import 'package:inspiria/core/utils/constant/api.dart';

class FavoriteService {
  static http.Client client = http.Client();
  static Future<FavoriteResponces?> getAllFavorite() async{
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getAllFavoriteEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        return FavoriteResponces(statusCode: response.statusCode, favoriteList: jsonList.map((json) => FavoriteModel.fromJson(json)).toList());
      } 
      else if (response.statusCode == 404) {
        return FavoriteResponces(statusCode: response.statusCode, errorMessage: 'Favorites not found');
      }
      else {
        return FavoriteResponces(statusCode: response.statusCode, errorMessage: 'Failed to load favorites');
      }
    } catch (e) {
      return FavoriteResponces(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<FavoriteResponce?> getFavoriteById(String id) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getFavoriteByIdEndpoint.replaceFirst("{id}", id)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return FavoriteResponce(statusCode: response.statusCode, favorite: FavoriteModel.fromJson(json.decode(response.body))); 
      } else if (response.statusCode == 404) {
        return FavoriteResponce(statusCode: response.statusCode, errorMessage: 'Favorite not found');
      } else {
        return FavoriteResponce(statusCode: response.statusCode, errorMessage: 'Failed to load favorite');
      }
    } catch (e) {
      return FavoriteResponce(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<FavoriteResponces?> getFavoritesByUserId(String userId) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getFavoriteByUserIdEndpoint.replaceFirst("{userId}", userId)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        
        return FavoriteResponces(statusCode: response.statusCode, favoriteList: jsonList.map((json) => FavoriteModel.fromJson(json)).toList());
      } 
      else if (response.statusCode == 404) {
        return FavoriteResponces(statusCode: response.statusCode, errorMessage: 'Favorites not found for user');
      }
      else {
        return FavoriteResponces(statusCode: response.statusCode, errorMessage: 'Failed to load favorites for user');
      }
    } catch (e) {
      return FavoriteResponces(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<FavoriteResponce?> createFavorite(Map<String, dynamic> favoriteData) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createFavoriteEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(favoriteData),
      );

      if (response.statusCode == 201) {
        return FavoriteResponce(statusCode: response.statusCode, favorite: FavoriteModel.fromJson(json.decode(response.body)));
      } else {
        return FavoriteResponce(statusCode: response.statusCode, errorMessage: 'Failed to create favorite');
      }
    } catch (e) {
      return FavoriteResponce(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<bool> deleteFavorite(String id) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.deleteFavoriteEndpoint.replaceFirst("{id}", id)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Favorite not found');
      } else {
        throw Exception('Failed to delete favorite');
      }
    } catch (e) {
      return false;
    }
  }

  static Future<FavoriteResponce?> updateFavorite(String id, Map<String, dynamic> favoriteData) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updateFavoriteEndpoint.replaceFirst("{id}", id)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(favoriteData),
      );

      if (response.statusCode == 200) {
        return FavoriteResponce(statusCode: response.statusCode, favorite: FavoriteModel.fromJson(json.decode(response.body)));
      } else if (response.statusCode == 404) {
        return FavoriteResponce(statusCode: response.statusCode, errorMessage: 'Favorite not found');
      } else {
        return FavoriteResponce(statusCode: response.statusCode, errorMessage: 'Failed to update favorite');
      }
    } catch (e) {
      return FavoriteResponce(statusCode: 500, errorMessage: e.toString());
    }
  }
}
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inspiria/core/api/token_storage.dart';
import 'package:inspiria/core/model/user_model.dart';
import 'package:inspiria/core/response/user_responce.dart';
import 'package:inspiria/core/utils/constant/api.dart';

class UserService {
  static Future<UserResponce?> getUserById(String id) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getUserByIdEndpoint.replaceFirst("{id}", id)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return UserResponce(statusCode: response.statusCode, user: UserModel.fromJson(json.decode(response.body)));
      } else if (response.statusCode == 404) {
        return UserResponce(statusCode: response.statusCode, errorMessage: 'User not found');
      } else {
        return UserResponce(statusCode: response.statusCode, errorMessage: 'Failed to load user');
      }
    } catch (e) {
      return UserResponce(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<UserResponces?> getAllUser() async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getAllUserEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return UserResponces(statusCode: response.statusCode, userList: jsonList.map((json) => UserModel.fromJson(json)).toList());
      } 
      else if (response.statusCode == 404) {
        return UserResponces(statusCode: response.statusCode, errorMessage: 'Users not found');
      }
      else {
        return UserResponces(statusCode: response.statusCode, errorMessage: 'Failed to load users');
      }
    } catch (e) {
      return UserResponces(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<UserResponce?> updateUser(String id, Map<String, dynamic> updatedData) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updateUserEndpoint.replaceFirst("{id}", id)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        return UserResponce(statusCode: response.statusCode, user: UserModel.fromJson(json.decode(response.body)));
      } else if (response.statusCode == 404) {
        return UserResponce(statusCode: response.statusCode, errorMessage: 'User not found');
      } else {
        return UserResponce(statusCode: response.statusCode, errorMessage: 'Failed to update user');
      }
    } catch (e) {
      return UserResponce(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<UserResponce?> createUser(Map<String, dynamic> userData) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createUserEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(userData),
      );

      if (response.statusCode == 201) {
        return UserResponce(statusCode: response.statusCode, user: UserModel.fromJson(json.decode(response.body)));
      } else {
        return UserResponce(statusCode: response.statusCode, errorMessage: 'Failed to create user');
      }
    } catch (e) {
      return UserResponce(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<bool> deleteUser(String id) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.deleteUserEndpoint.replaceFirst("{id}", id)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        throw Exception('Failed to delete user');
      }
    } catch (e) {
      return false;
    }
  }
}

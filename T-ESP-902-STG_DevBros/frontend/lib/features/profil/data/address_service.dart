import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inspiria/core/api/token_storage.dart';
import 'package:inspiria/core/model/address_model.dart';
import 'package:inspiria/core/response/address_responce.dart';
import 'package:inspiria/core/utils/constant/api.dart';

class AddressService {
  static Future<AddressResponces?> getAllAddress() async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.getAllAddressEndpoint}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return AddressResponces(
          statusCode: response.statusCode,
          address: jsonList.map((json) => AddressModel.fromJson(json)).toList(),
        );
      } else if (response.statusCode == 404) {
        return AddressResponces(
          statusCode: response.statusCode,
          errorMessage: 'No addresses found',
        );
      } else {
        throw Exception('Failed to load addresses');
      }
    } catch (e) {
      return AddressResponces(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<AddressResponce?> getAddressById(String id) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.getAddressByIdEndpoint.replaceFirst("{id}", id)}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return AddressResponce(
          statusCode: response.statusCode,
          address: AddressModel.fromJson(json.decode(response.body)),
        );
      } else if (response.statusCode == 404) {
        return AddressResponce(
          statusCode: response.statusCode,
          errorMessage: 'Address not found',
        );
      } else {
        return AddressResponce(
          statusCode: response.statusCode,
          errorMessage: 'Failed to load address',
        );
      }
    } catch (e) {
      return AddressResponce(
        statusCode: 500,
        errorMessage: e.toString(),
      );
    }
  }

  static Future<AddressResponces?> getAddressByUserId(String userId) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.getAddressByUserIdEndpoint.replaceFirst("{userId}", userId)}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return AddressResponces(statusCode: response.statusCode, address: jsonList.map((json) => AddressModel.fromJson(json)).toList());
      } else if (response.statusCode == 404) {
        return AddressResponces(statusCode: response.statusCode, errorMessage: 'Addresses not found for user');
      } else {
        return AddressResponces(statusCode: response.statusCode, errorMessage: 'Failed to load addresses for user');
      }
    } catch (e) {
      return AddressResponces(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<AddressResponce?> createAddress(AddressModel address) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.post(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.createAddressEndpoint}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(address.toJson()),
      );

      if (response.statusCode == 201) {
        return AddressResponce(statusCode: response.statusCode, address: AddressModel.fromJson(json.decode(response.body)));
      } else {
        return AddressResponce(statusCode: response.statusCode, errorMessage: 'Failed to create address');
      }
    } catch (e) {
      return AddressResponce(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<AddressResponce?> updateAddress(
    String id,
    AddressModel address,
  ) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.put(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.updateAddressEndpoint.replaceFirst("{id}", id)}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(address.toJson()),
      );

      if (response.statusCode == 200) {
        return AddressResponce(statusCode: response.statusCode, address: AddressModel.fromJson(json.decode(response.body)));
      } else if (response.statusCode == 404) {
        return AddressResponce(statusCode: response.statusCode, errorMessage: 'Address not found');
      } else {
        return AddressResponce(statusCode: response.statusCode, errorMessage: 'Failed to update address');
      }
    } catch (e) {
      return AddressResponce(statusCode: 500, errorMessage: e.toString());
    }
  }

  static Future<bool> deleteAddress(String id) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final response = await http.delete(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.deleteAddressEndpoint.replaceFirst("{id}", id)}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Address not found');
      } else {
        throw Exception('Failed to delete address');
      }
    } catch (e) {
      return false;
    }
  }
}

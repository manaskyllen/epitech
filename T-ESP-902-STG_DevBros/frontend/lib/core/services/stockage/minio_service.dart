import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:inspiria/core/api/token_storage.dart';
import 'package:inspiria/core/utils/constant/api.dart';

class MinioService {
  static Future<String?> uploadFile(File file) async {
    try {
      final token = await TokenStorage().getAccessToken();

      final request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiConstants.baseUrl}${ApiConstants.minioUploadEndpoint}')
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final responseData = json.decode(responseBody);
        return responseData['path'];
      } else {
        throw Exception('Failed to upload file');
      }
    } catch (e) {
      return null;
    }
  }

  static Future<Uint8List?> getFile(String filename) async {
    try {
      final apiKey = dotenv.env['API_KEY'] ?? '';
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.minioGetElementEndpoint.replaceFirst("{filename}", filename)}'),
        headers: {
          'X-API-KEY': apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 404) {
        throw Exception('File not found');
      } else {
        throw Exception('Failed to load file');
      }
    } catch (e) {
      return null;
    }
  }
}
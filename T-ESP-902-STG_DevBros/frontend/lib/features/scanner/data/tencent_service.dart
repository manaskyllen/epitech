import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:inspiria/core/api/token_storage.dart';
import 'package:inspiria/core/model/tencent_model.dart';
import 'package:inspiria/core/response/tencent_responce.dart';
import 'package:inspiria/core/utils/constant/api.dart';


class TencentService {
  static final Uri uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.convertImageEndpoint}'); 

  Future<TencentResponce> convertImageToGlb(TencentRequest request) async {
    try {
      final multipartRequest = http.MultipartRequest('POST', uri);

      final token = await TokenStorage().getAccessToken();

      if (token == null) {
      throw Exception('Utilisateur non connecté (Token absent)');
    }

    multipartRequest.headers.addAll({
  'Authorization': 'Bearer $token',      
  'Accept': 'application/json',          
});
      final userId = await TokenStorage().getUserId();


      
      multipartRequest.fields['itemType'] = request.itemType;
      multipartRequest.fields['itemSubtype'] = request.itemSubtype;
      multipartRequest.fields['user_id'] = userId.toString();

      final stream = http.ByteStream(request.imageFile.openRead());
      final length = await request.imageFile.length();

      final multipartFile = http.MultipartFile(
        'file',
        stream,
        length,
        filename: request.imageFile.path.split('/').last,
      );

      multipartRequest.files.add(multipartFile);

      final streamedResponse = await multipartRequest.send();

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);
        debugPrint('TencentService response: $jsonMap');
        return TencentResponce.fromJson(jsonMap);
      } else {
        try {
          final jsonMap = jsonDecode(response.body);
          debugPrint('Erreur ${response.statusCode} : ${response.body}');
          throw Exception(jsonMap['error'] ?? 'Erreur inconnue: ${response.body}');
        } catch (e) {
          throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
        }
      }
    } catch (e) {
      // Gestion des erreurs réseaux
      throw Exception('Echec de la connexion au service: $e');
    }
  }
}
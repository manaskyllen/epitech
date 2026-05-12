import 'dart:convert';
import 'package:flutter/foundation.dart'; // Required for debugPrint
import 'package:http/http.dart' as http;

class CitySuggestion {
  const CitySuggestion({required this.name, required this.fullAddress});

  final String name;
  final String fullAddress;
}

class CityService {
  static Future<List<CitySuggestion>> searchCities(String query) async {
    if (query.length < 3) return [];

    // URL Photon
    final url = Uri.parse('https://photon.komoot.io/api/?q=$query&limit=5');

    try {
      // AJOUT DE HEADERS : Très important pour éviter la 403
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'InspiriaTravelApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> features = data['features'];

        return features.map((item) {
          final props = item['properties'];
          final String city = props['name'] ?? 'Unknown';
          final String country = props['country'] ?? '';
          final String state = props['state'] ?? '';

          return CitySuggestion(
            name: city,
            fullAddress: state.isNotEmpty ? '$state, $country' : country,
          );
        }).toList();
      } else {
        // use debugPrint instead of print
        debugPrint('Erreur Photon ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      // use debugPrint instead of print
      debugPrint('Erreur réseau Photon: $e');
      return [];
    }
  }
}
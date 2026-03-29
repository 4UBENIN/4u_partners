import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show Response;
import 'package:for_u_partners/services/sharedpreferences_service.dart';

class FunctionsService {
  final SharedpreferencesService storage = SharedpreferencesService();
  final String baseUrl = 'https://foryou.cilassocies.com/api';

  // Helper method to handle HTTP requests
  Future<Response> _makeRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final token = await storage.getToken();
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    final uri = Uri.parse('$baseUrl/$endpoint');

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          return await http.get(uri, headers: defaultHeaders);
        case 'POST':
          return await http.post(
            uri,
            headers: defaultHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
        case 'PUT':
          return await http.put(
            uri,
            headers: defaultHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
        case 'DELETE':
          return await http.delete(
            uri,
            headers: defaultHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
    } catch (e) {
      print('Error making $method request to $endpoint: $e');
      rethrow;
    }
  }

 Future<List<Map<String, String>>> getAddressSuggestions(String query) async {
  try {
    if (query.isEmpty || query.length < 3) return [];

    // 🔐 Vérification du token
    final token = await storage.getToken();
    if (token == null) {
      print('❌ Aucun token trouvé! L\'utilisateur doit être connecté.');
      return [];
    }
    print('✅ Token présent: ${token.substring(0, 20)}...');

    print('🔍 Recherche: $query');

    // 🎯 Appel à ton API backend - CORRECTION ICI ✨
    final response = await _makeRequest(
      'places/autocomplete?input=${Uri.encodeComponent(query)}',  // ← Changé de 'query' à 'input'
      method: 'GET',
    );

    print('📡 Response status: ${response.statusCode}');
    print('📦 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final suggestions = data['suggestions'] as List;

      print('✅ Suggestions trouvées: ${suggestions.length}');

      final results = suggestions.map((suggestion) {
        return {
          'description': suggestion['description'] as String,
          'place_id': suggestion['place_id'] as String,
          'coordinates': '', // On récupère les coords avec getPlaceDetails
        };
      }).toList();

      // Debug: affiche les résultats
      if (results.isNotEmpty) {
        print('📍 Résultats:');
        for (var i = 0; i < results.length; i++) {
          print('   ${i + 1}. ${results[i]['description']}');
        }
      }

      return results;
    } else {
      print('❌ Erreur HTTP: ${response.statusCode}');
      print('❌ Body: ${response.body}');
    }

    return [];
  } catch (e) {
    print('❌ ERROR in getAddressSuggestions: $e');
    return [];
  }
}

// 🎯 Récupère les détails (coordonnées) d'un lieu sélectionné
Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
  try {
    print('🔍 Récupération des détails pour: $placeId');

    final response = await _makeRequest(
      'places/details?place_id=${Uri.encodeComponent(placeId)}',
      method: 'GET',
    );

    print('📡 Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      print('✅ Détails récupérés:');
      print('   📍 ${data['name'] ?? data['address']}');
      print('   🌍 ${data['latitude']}, ${data['longitude']}');

      return {
        'address': data['address'] as String,
        'name': data['name'] as String?,
        'latitude': data['latitude'] as double,
        'longitude': data['longitude'] as double,
      };
    } else {
      print('❌ Erreur HTTP: ${response.statusCode}');
      print('❌ Body: ${response.body}');
    }

    return {};
  } catch (e) {
    print('❌ ERROR in getPlaceDetails: $e');
    return {};
  }
}
}
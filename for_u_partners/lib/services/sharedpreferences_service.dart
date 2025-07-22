import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedpreferencesService {
  static const String _tokenKey = 'user_token';

  // Enregistre n'importe quel type de valeur en la convertissant en JSON
  Future<void> saveToken(dynamic token) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonToken = jsonEncode(token);
    await prefs.setString(_tokenKey, jsonToken);
  }

  // Récupère le token (brut ou reconverti en Map, selon besoin)
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Supprimer le token
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}

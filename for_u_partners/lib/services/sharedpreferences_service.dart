import 'package:shared_preferences/shared_preferences.dart';

class SharedpreferencesService {
  static const String _tokenKey = 'user_token';
  static const String _userType = 'user_type';
  static const String _userTypeId = 'user_type_id';
  static const String _userId = 'user_id';
  static const String _userName = 'user_name';

  //* USER TOKEN

  // Enregistre n'importe quel type de valeur en la convertissant en JSON
  Future<void> saveToken(dynamic token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
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

  //* USER TYPE

  // Enregistre le type de l'utilisateur en la convertissant en JSON
  Future<void> saveUserType(dynamic type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userType, type);
  }

  // Récupère le type de l'utilisateur (brut ou reconverti en Map, selon besoin)
  Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userType);
  }

  // Supprimer le Type de l'utilisateur
  Future<void> removeUserType() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userType);
  }

  //* USER ID

  // Enregistre l'ID de l'utilisateur en la convertissant en JSON
  Future<void> saveUserId(dynamic id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userId, id);
  }

  // Récupère l'ID de l'utilisateur (brut ou reconverti en Map, selon besoin)
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userId);
  }

  // Supprimer l'ID de l'utilisateur
  Future<void> removeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userId);
  }

  //* USER TYPE ID

    // Enregistre l'ID de l'utilisateur en la convertissant en JSON
  Future<void> saveUserTypeId(dynamic id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userTypeId, id);
  }

  // Récupère l'ID de l'utilisateur (brut ou reconverti en Map, selon besoin)
  Future<String?> getUserTypeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTypeId);
  }

  // Supprimer l'ID de l'utilisateur
  Future<void> removeUserTypeId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userTypeId);
  }

  //* USER NAME

  // Enregistre le nom de l'utilisateur en la convertissant en JSON
  Future<void> saveUserName(dynamic name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userName, name);
  }

  // Récupère le nom de l'utilisateur (brut ou reconverti en Map, selon besoin)
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userName);
  }

  // Supprimer le nom de l'utilisateur
  Future<void> removeUserName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userName);
  }
}

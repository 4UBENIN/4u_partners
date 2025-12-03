import 'package:shared_preferences/shared_preferences.dart';
import 'package:for_u_partners/ui/views/delivery/courses_delivery/courses_delivery_viewmodel.dart';

class SharedpreferencesService {
  static const String _tokenKey = 'user_token';
  static const String _userType = 'user_type';
  static const String _userId = 'user_id';
  static const String _userTypeId = 'user_type_id';
  static const String _userName = 'user_name';
  static const String _profilStatuts = 'profil_statuts';
  static const String _onlineStatus = 'driver_online_status';
  static const String _activeVehicleType = 'active_vehicle_type';

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

  // Enregistrer l'état en ligne/hors ligne
  Future<void> setOnlineStatus(bool isOnline) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onlineStatus, isOnline);
  }

  // Récupérer l'état enregistré
  Future<bool?> getOnlineStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onlineStatus);
  }

  //* Gestion de l'état du bottom sheet
  static const String _bottomSheetTypeKey = 'ramassage_bottom_sheet_type';
  static const String _acceptedDemandeIdKey = 'accepted_demande_id';

  // Sauvegarder le type de bottom sheet
  Future<void> setBottomSheetType(RamassageBottomSheetType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bottomSheetTypeKey, type.toString());
  }

  // Récupérer le type de bottom sheet
  Future<RamassageBottomSheetType?> getBottomSheetType() async {
    final prefs = await SharedPreferences.getInstance();
    final typeString = prefs.getString(_bottomSheetTypeKey);
    if (typeString == null) return null;

    return RamassageBottomSheetType.values.firstWhere(
      (e) => e.toString() == typeString,
      orElse: () => RamassageBottomSheetType.none,
    );
  }

  // Sauvegarder l'ID de la demande acceptée
  Future<void> setAcceptedDemandeId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_acceptedDemandeIdKey, id);
  }

  // Récupérer l'ID de la demande acceptée
  Future<String?> getAcceptedDemandeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_acceptedDemandeIdKey);
  }

  // Effacer l'état du bottom sheet
  Future<void> clearBottomSheetState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bottomSheetTypeKey);
    await prefs.remove(_acceptedDemandeIdKey);
  }

  //* USER ID

  // Enregistre l'ID de l'utilisateur (gère à la fois String et int)
  Future<void> saveUserId(dynamic id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id is String) {
      await prefs.setString(_userId, id);
    } else if (id is int) {
      await prefs.setString(_userId, id.toString());
    } else {
      throw ArgumentError('ID must be either String or int');
    }
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

  //* PROFIL STATUTS

  // Enregistre le statut du profil en la convertissant en JSON
  Future<void> saveProfilStatuts(dynamic statuts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profilStatuts, statuts);
  }

  // Récupère le statut du profil (brut ou reconverti en Map, selon besoin)
  Future<String?> getProfilStatuts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profilStatuts);
  }

  // Supprimer le statut du profil
  Future<void> removeProfilStatuts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profilStatuts);
  }

  //* ACTIVE VEHICLE TYPE

  // Enregistre le type de véhicule actif (moto, voiture, etc.)
  Future<void> saveActiveVehicleType(String vehicleType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeVehicleType, vehicleType);
  }

  // Récupère le type de véhicule actif
  Future<String?> getActiveVehicleType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeVehicleType);
  }

  // Supprimer le type de véhicule actif
  Future<void> removeActiveVehicleType() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeVehicleType);
  }
}

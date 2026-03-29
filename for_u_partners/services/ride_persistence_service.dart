import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RidePersistenceService {
  static const String _currentRideKey = 'current_ride_data';
  static const String _rideStatusKey = 'current_ride_status';

  // Sauvegarder l'état de la course
  static Future<void> saveRideState(
      Map<String, dynamic> rideData, String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentRideKey, jsonEncode(rideData));
    await prefs.setString(_rideStatusKey, status);
  }

  // Récupérer l'état de la course
  static Future<Map<String, dynamic>?> getRideState() async {
    final prefs = await SharedPreferences.getInstance();
    final rideData = prefs.getString(_currentRideKey);
    if (rideData != null) {
      return jsonDecode(rideData) as Map<String, dynamic>;
    }
    return null;
  }

  // Récupérer le statut de la course
  static Future<String?> getRideStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_rideStatusKey);
  }

  // Supprimer l'état de la course (quand la course est terminée)
  static Future<void> clearRideState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentRideKey);
    await prefs.remove(_rideStatusKey);
  }

  // Vérifier si une course est en cours
  static Future<bool> hasActiveRide() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_currentRideKey);
  }
}

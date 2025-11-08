import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';

/// Real-time location tracking service with local storage
/// Provides smooth, continuous location updates without blocking UI
class LocationTrackingService {
  static final LocationTrackingService _instance = LocationTrackingService._internal();
  factory LocationTrackingService() => _instance;
  LocationTrackingService._internal();

  final loc.Location _location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;

  // Stream controller for location updates
  final _locationController = StreamController<loc.LocationData>.broadcast();
  Stream<loc.LocationData> get locationStream => _locationController.stream;

  // Current location cache
  loc.LocationData? _currentLocation;
  loc.LocationData? get currentLocation => _currentLocation;

  // SharedPreferences keys
  static const String _keyLatitude = 'last_location_latitude';
  static const String _keyLongitude = 'last_location_longitude';
  static const String _keyAccuracy = 'last_location_accuracy';
  static const String _keyTimestamp = 'last_location_timestamp';

  bool _isTracking = false;
  bool get isTracking => _isTracking;

  /// Initialize and load last known location from storage
  Future<loc.LocationData?> initialize() async {
    try {
      debugPrint('📍 [LocationTracking] Initializing...');

      // Check permissions
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          debugPrint('❌ [LocationTracking] Location service not enabled');
          return await _loadLastKnownLocation();
        }
      }

      loc.PermissionStatus permission = await _location.hasPermission();
      if (permission == loc.PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission != loc.PermissionStatus.granted) {
          debugPrint('❌ [LocationTracking] Location permission denied');
          return await _loadLastKnownLocation();
        }
      }

      // Load last known location from storage (instant)
      final lastKnown = await _loadLastKnownLocation();
      if (lastKnown != null) {
        _currentLocation = lastKnown;
        debugPrint('✅ [LocationTracking] Loaded last known location from storage');
      }

      // Configure location settings for real-time tracking
      await _location.changeSettings(
        accuracy: loc.LocationAccuracy.high,
        interval: 5000, // Update every 5 seconds
        distanceFilter: 10, // Only update if moved 10 meters
      );

      debugPrint('✅ [LocationTracking] Initialized successfully');
      return lastKnown;
    } catch (e) {
      debugPrint('❌ [LocationTracking] Initialization error: $e');
      return await _loadLastKnownLocation();
    }
  }

  /// Start real-time location tracking
  Future<void> startTracking() async {
    if (_isTracking) {
      debugPrint('⚠️ [LocationTracking] Already tracking');
      return;
    }

    try {
      debugPrint('🎯 [LocationTracking] Starting real-time tracking...');

      _locationSubscription = _location.onLocationChanged.listen(
        (loc.LocationData locationData) {
          _currentLocation = locationData;
          _locationController.add(locationData);

          // Save to storage asynchronously (non-blocking)
          _saveLocationToStorage(locationData);

          debugPrint(
            '📍 [LocationTracking] Updated: '
            '${locationData.latitude?.toStringAsFixed(6)}, '
            '${locationData.longitude?.toStringAsFixed(6)}',
          );
        },
        onError: (error) {
          debugPrint('❌ [LocationTracking] Stream error: $error');
        },
      );

      _isTracking = true;
      debugPrint('✅ [LocationTracking] Real-time tracking started');
    } catch (e) {
      debugPrint('❌ [LocationTracking] Failed to start tracking: $e');
    }
  }

  /// Stop real-time location tracking
  Future<void> stopTracking() async {
    if (!_isTracking) return;

    try {
      await _locationSubscription?.cancel();
      _locationSubscription = null;
      _isTracking = false;
      debugPrint('🛑 [LocationTracking] Tracking stopped');
    } catch (e) {
      debugPrint('❌ [LocationTracking] Error stopping tracking: $e');
    }
  }

  /// Get current location once (fallback method)
  Future<loc.LocationData?> getCurrentLocation() async {
    try {
      final locationData = await _location.getLocation();
      _currentLocation = locationData;
      await _saveLocationToStorage(locationData);
      return locationData;
    } catch (e) {
      debugPrint('❌ [LocationTracking] Error getting current location: $e');
      return _currentLocation ?? await _loadLastKnownLocation();
    }
  }

  /// Load last known location from SharedPreferences
  Future<loc.LocationData?> _loadLastKnownLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final latitude = prefs.getDouble(_keyLatitude);
      final longitude = prefs.getDouble(_keyLongitude);
      final accuracy = prefs.getDouble(_keyAccuracy);
      final timestamp = prefs.getInt(_keyTimestamp);

      if (latitude == null || longitude == null) {
        debugPrint('⚠️ [LocationTracking] No stored location found');
        return null;
      }

      // Check if location is too old (more than 1 hour)
      if (timestamp != null) {
        final age = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (age > 3600000) { // 1 hour in milliseconds
          debugPrint('⚠️ [LocationTracking] Stored location is too old');
        }
      }

      debugPrint(
        '📦 [LocationTracking] Loaded stored location: '
        '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
      );

      return loc.LocationData.fromMap({
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy ?? 0.0,
        'time': timestamp?.toDouble(),
      });
    } catch (e) {
      debugPrint('❌ [LocationTracking] Error loading stored location: $e');
      return null;
    }
  }

  /// Save location to SharedPreferences (non-blocking)
  Future<void> _saveLocationToStorage(loc.LocationData locationData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await Future.wait([
        prefs.setDouble(_keyLatitude, locationData.latitude ?? 0.0),
        prefs.setDouble(_keyLongitude, locationData.longitude ?? 0.0),
        prefs.setDouble(_keyAccuracy, locationData.accuracy ?? 0.0),
        prefs.setInt(_keyTimestamp, DateTime.now().millisecondsSinceEpoch),
      ]);

      debugPrint('💾 [LocationTracking] Location saved to storage');
    } catch (e) {
      debugPrint('❌ [LocationTracking] Error saving location: $e');
    }
  }

  /// Clear stored location
  Future<void> clearStoredLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_keyLatitude),
        prefs.remove(_keyLongitude),
        prefs.remove(_keyAccuracy),
        prefs.remove(_keyTimestamp),
      ]);
      debugPrint('🧹 [LocationTracking] Stored location cleared');
    } catch (e) {
      debugPrint('❌ [LocationTracking] Error clearing location: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    stopTracking();
    _locationController.close();
  }
}

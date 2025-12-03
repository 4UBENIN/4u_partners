import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Service for loading and caching custom map marker icons
class MarkerIconService {
  // Cache for loaded markers
  static BitmapDescriptor? _driverMarker;
  static BitmapDescriptor? _driverMarkerMoto;
  static BitmapDescriptor? _pickupMarker;
  static BitmapDescriptor? _destinationMarker;

  /// Get driver position marker based on vehicle type
  /// [vehicleType] - Type of vehicle (e.g., "moto", "voiture", etc.)
  /// If vehicleType is "moto", returns motorcycle marker, otherwise returns car marker
  static Future<BitmapDescriptor> getDriverMarker({String? vehicleType}) async {
    // Use motorcycle marker if vehicle type is "moto"
    if (vehicleType?.toLowerCase() == 'moto') {
      if (_driverMarkerMoto != null) return _driverMarkerMoto!;
      _driverMarkerMoto = await _loadSvgMarker(
        'assets/markers/driver_marker_moto.svg',
        width: 50,
      );
      return _driverMarkerMoto!;
    }

    // Default to car marker
    if (_driverMarker != null) return _driverMarker!;
    _driverMarker = await _loadSvgMarker(
      'assets/markers/driver_marker.svg',
      width: 50,
    );
    return _driverMarker!;
  }

  /// Get pickup/departure location marker
  static Future<BitmapDescriptor> getPickupMarker() async {
    if (_pickupMarker != null) return _pickupMarker!;
    _pickupMarker = await _loadSvgMarker(
      'assets/markers/pickup_marker.svg',
      width: 50,
    );
    return _pickupMarker!;
  }

  /// Get destination marker
  static Future<BitmapDescriptor> getDestinationMarker() async {
    if (_destinationMarker != null) return _destinationMarker!;
    _destinationMarker = await _loadSvgMarker(
      'assets/markers/destination_marker.svg',
      width: 50,
    );
    return _destinationMarker!;
  }

  /// Load SVG marker from asset with specified size
  static Future<BitmapDescriptor> _loadSvgMarker(
    String assetPath, {
    int width = 50,
  }) async {
    try {
      debugPrint('📍 [Marker] Loading SVG marker from: $assetPath');

      // Load SVG string
      final String svgString = await rootBundle.loadString(assetPath);

      // Parse SVG and get picture
      final PictureInfo pictureInfo = await vg.loadPicture(
        SvgStringLoader(svgString),
        null,
      );

      // Get SVG dimensions
      final double svgWidth = pictureInfo.size.width;
      final double svgHeight = pictureInfo.size.height;
      final double aspectRatio = svgHeight / svgWidth;
      final int targetHeight = (width * aspectRatio).round();

      // Account for device pixel ratio for crisp rendering
      final double devicePixelRatio =
          WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
      final int renderWidth = (width * devicePixelRatio).round();
      final int renderHeight = (targetHeight * devicePixelRatio).round();

      debugPrint(
        '📍 [Marker] SVG original: ${svgWidth}x${svgHeight}, '
        'target: ${width}x$targetHeight, '
        'render: ${renderWidth}x$renderHeight (ratio: $devicePixelRatio)',
      );

      // Create a picture recorder for rendering
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      // Scale for both target size and device pixel ratio
      final double scale = renderWidth / svgWidth;
      canvas.scale(scale);
      canvas.drawPicture(pictureInfo.picture);

      // Convert to high-res image
      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(renderWidth, renderHeight);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      // Dispose resources
      pictureInfo.picture.dispose();
      image.dispose();

      if (byteData == null) {
        debugPrint('❌ [Marker] Failed to convert SVG to bytes: $assetPath');
        throw Exception('Failed to convert SVG to bytes');
      }

      debugPrint('✅ [Marker] Successfully loaded SVG: $assetPath');
      return BitmapDescriptor.bytes(
        byteData.buffer.asUint8List(),
        width: width.toDouble(),
        height: targetHeight.toDouble(),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [Marker] Error loading SVG marker from $assetPath: $e');
      debugPrint('❌ [Marker] Stack trace: $stackTrace');
      debugPrint('⚠️ [Marker] Using default marker as fallback');
      return BitmapDescriptor.defaultMarker;
    }
  }

  /// Clear cached markers (useful for memory management)
  static void clearCache() {
    _driverMarker = null;
    _driverMarkerMoto = null;
    _pickupMarker = null;
    _destinationMarker = null;
  }

  /// Preload all markers (call during app initialization)
  /// [vehicleType] - Optional vehicle type to preload specific driver marker
  static Future<void> preloadMarkers({String? vehicleType}) async {
    await Future.wait([
      getDriverMarker(vehicleType: vehicleType),
      getPickupMarker(),
      getDestinationMarker(),
    ]);
    debugPrint('✅ All custom SVG markers preloaded');
  }
}

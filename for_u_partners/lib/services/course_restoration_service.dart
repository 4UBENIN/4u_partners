import 'package:flutter/material.dart';

/// Service to temporarily hold active course data for restoration
/// This allows passing data from app lifecycle to view initialization
class CourseRestorationService {
  Map<String, dynamic>? _pendingRestoration;

  /// Set course data pending restoration
  void setPendingRestoration(Map<String, dynamic>? courseData) {
    _pendingRestoration = courseData;
    debugPrint('📦 Course restoration data set: ${courseData != null}');
  }

  /// Get and clear pending restoration data
  Map<String, dynamic>? consumePendingRestoration() {
    final data = _pendingRestoration;
    _pendingRestoration = null;
    debugPrint('📦 Course restoration data consumed: ${data != null}');
    return data;
  }

  /// Check if there's pending restoration
  bool hasPendingRestoration() {
    return _pendingRestoration != null;
  }

  /// Clear pending restoration without consuming
  void clearPendingRestoration() {
    _pendingRestoration = null;
    debugPrint('📦 Course restoration data cleared');
  }
}

import 'package:flutter/material.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/driver_service.dart';

/// Service to check for active courses when app starts or resumes
class ActiveCourseCheckerService {
  final _driverService = locator<DriverService>();

  /// Active statuses for driver app
  static const List<String> activeStatuses = [
    'chauffeur_en_route', // Driver heading to pickup
    'en_route_vers_client', // Driver heading to client
    'arrive_au_point_depart', // Driver arrived at pickup
    'en_cours', // Trip in progress
    'en_pause', // Trip paused
    'en_attente_paiement', // Waiting for payment
  ];

  /// Check if there's an active course for the current driver
  /// Returns the course details if found, null otherwise
  Future<Map<String, dynamic>?> checkForActiveCourse() async {
    try {
      debugPrint('🔍 Checking for active course...');

      // 1. Fetch all courses for the driver
      final courses = await _driverService.getCoursesList();
      debugPrint('📋 Found ${courses.length} courses');

      // 2. Filter courses by active statuses
      final activeCourses = courses.where((course) {
        final status = course['statut'] as String?;
        return status != null && activeStatuses.contains(status);
      }).toList();

      debugPrint('✅ Found ${activeCourses.length} active courses');

      if (activeCourses.isEmpty) {
        debugPrint('ℹ️ No active course found');
        return null;
      }

      // 3. Sort by creation date (most recent first) and get the first one
      activeCourses.sort((a, b) {
        final dateA = DateTime.tryParse(a['créée_le'] ?? '') ?? DateTime(1970);
        final dateB = DateTime.tryParse(b['créée_le'] ?? '') ?? DateTime(1970);
        return dateB.compareTo(dateA); // Most recent first
      });

      final mostRecentActive = activeCourses.first;
      final courseId = mostRecentActive['id'] as int;
      final status = mostRecentActive['statut'] as String;

      debugPrint('🎯 Most recent active course: ID=$courseId, Status=$status');

      // 4. Fetch full course details
      final courseDetails = await _driverService.getCourseDetails(courseId);

      debugPrint('✅ Active course details retrieved successfully');

      return courseDetails;
    } catch (e) {
      debugPrint('❌ Error checking for active course: $e');
      return null;
    }
  }

  /// Check if a course status is active
  static bool isStatusActive(String status) {
    return activeStatuses.contains(status);
  }
}

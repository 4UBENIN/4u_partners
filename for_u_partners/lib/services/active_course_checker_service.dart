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
    'chauffeur_arrive', // Driver confirmed arrival
    'en_cours', // Trip in progress
    'en_pause', // Trip paused
    'en_attente_paiement', // Waiting for payment
  ];

  /// Check if there's an active course for the current driver
  /// Returns the course details if found, null otherwise
  /// Checks both regular courses AND pickup courses
  Future<Map<String, dynamic>?> checkForActiveCourse() async {
    try {
      debugPrint('🔍 Checking for active course (regular + pickup)...');

      // STEP 1: Check for active pickup courses first
      debugPrint('🔍 Step 1: Checking pickup courses...');
      try {
        final activePickupCourse = await _driverService.getActivePickupCourse();
        if (activePickupCourse != null) {
          debugPrint('✅ Found active PICKUP course: ${activePickupCourse['id']}');
          // Add a flag to indicate this is a pickup course
          activePickupCourse['is_pickup_course'] = true;
          return activePickupCourse;
        }
      } catch (e) {
        debugPrint('⚠️ Error checking pickup courses: $e');
        // Continue to check regular courses
      }

      // STEP 2: Check for active regular courses
      debugPrint('🔍 Step 2: Checking regular courses...');

      // 2.1. Fetch all regular courses for the driver
      final courses = await _driverService.getCoursesList();
      debugPrint('📋 Found ${courses.length} regular courses');

      // 2.2. Filter courses by active statuses
      final activeCourses = courses.where((course) {
        final status = course['statut'] as String?;
        return status != null && activeStatuses.contains(status);
      }).toList();

      debugPrint('✅ Found ${activeCourses.length} active regular courses');

      if (activeCourses.isEmpty) {
        debugPrint('ℹ️ No active course found (neither pickup nor regular)');
        return null;
      }

      // 2.3. Sort by creation date (most recent first) and get the first one
      activeCourses.sort((a, b) {
        final dateA = DateTime.tryParse(a['créée_le'] ?? '') ?? DateTime(1970);
        final dateB = DateTime.tryParse(b['créée_le'] ?? '') ?? DateTime(1970);
        return dateB.compareTo(dateA); // Most recent first
      });

      final mostRecentActive = activeCourses.first;
      final courseId = mostRecentActive['id'] as int;
      final status = mostRecentActive['statut'] as String;

      debugPrint('🎯 Most recent active regular course: ID=$courseId, Status=$status');

      // 2.4. Fetch full course details
      final courseDetails = await _driverService.getCourseDetails(courseId);

      debugPrint('✅ Active regular course details retrieved successfully');
      debugPrint('📋 Course details keys: ${courseDetails.keys.toList()}');

      // Add a flag to indicate this is NOT a pickup course
      courseDetails['is_pickup_course'] = false;

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

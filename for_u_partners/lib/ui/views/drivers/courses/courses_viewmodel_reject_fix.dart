import 'package:for_u_partners/services/local_notif_service.dart';
import 'package:for_u_partners/ui/views/drivers/courses/model/client_model.dart';
import 'package:for_u_partners/services/driver_service.dart';

Future<void> rejectCourse({
  required ClientData currentCourse,
  String? reason,
}) async {
  try {
    // Check if courseId is valid
    if (currentCourse.courseId == null || currentCourse.courseId!.isEmpty) {
      throw Exception('Course ID is required');
    }

    // Call the API to reject the course
    await DriverService().rejectCourse(
      int.parse(currentCourse.courseId!),
    );

    // Show cancellation notification
    await LocalNotificationService.showCourseAbortedNotification(
      courseId: currentCourse.courseId!,
    );

    // Note: The parent viewmodel should handle state management
    // The following methods should be called by the parent viewmodel:
    // - _saveRideState('rejected')
    // - _resetCourseState()
    
    return;
  } catch (e) {
    print('❌ Erreur lors de l\'annulation de la course: $e');
    rethrow;
  }
}

import 'package:flutter_dotenv/flutter_dotenv.dart';

String get baseUrl => dotenv.env['API_ENDPOINT']!;
String get registerUrl => "$baseUrl/partenaire/register";
String get loginUrl => "$baseUrl/partenaire/login";
String get sendOtpUrl => "$baseUrl/partenaire/send-code";
String get verifyOtpUrl => "$baseUrl/partenaire/verify-code";
String get coursesPendingUrl => "$baseUrl/conducteur/courses";
String acceptCourseUrl(int courseId) =>
    "$baseUrl/conducteur/courses/$courseId/accept";
String rejectCourseUrl(int courseId) =>
    "$baseUrl/conducteur/courses/$courseId/deny";
String startCourseUrl(int courseId) =>
    "$baseUrl/conducteur/courses/$courseId/start";
String requestPauseUrl(int courseId) =>
    "$baseUrl/conducteur/courses/$courseId/demande_pause";
String startPauseUrl(int courseId) =>
    "$baseUrl/conducteur/courses/$courseId/start_pause";
String stopPauseUrl(int courseId) =>
    "$baseUrl/conducteur/courses/$courseId/stop_pause";
String completeCourseUrl(int courseId) =>
    "$baseUrl/conducteur/courses/$courseId/finish";
String factureCourseUrl(int courseId) =>
    "$baseUrl/conducteur/courses/$courseId/facture";
String coursesDetailsUrl(int courseId) =>
    "$baseUrl/conducteur/courses/$courseId/details";
String get assignedCourseUrl => "$baseUrl/conducteur/courses_list";
String get walletSoldUrl => "$baseUrl/wallet_solde";
String get getDailyStats => "$baseUrl/conducteur/stats/daily";
String get getGlobalStats => "$baseUrl/conducteur/stats/global";

// Pickup Course URLs
String get createPickupCourseUrl => "$baseUrl/conducteur/course_pickup/lancer_course";
String get listPickupCoursesUrl => "$baseUrl/conducteur/courses_list";
String pickupCourseDetailsUrl(int courseId) =>
    "$baseUrl/conducteur/courses/$courseId/detail";
String startPickupCourseUrl(int courseId) =>
    "$baseUrl/conducteur/course_pickup/$courseId/start";
String finishPickupCourseUrl(int courseId) =>
    "$baseUrl/conducteur/course_pickup/$courseId/finish";
String markPickupCoursePaidUrl(int courseId) =>
    "$baseUrl/conducteur/course_pickup/$courseId/payment";
String startPickupPauseUrl(int courseId) =>
    "$baseUrl/conducteur/course_pickup/$courseId/start_pause";
String stopPickupPauseUrl(int courseId) =>
    "$baseUrl/conducteur/course_pickup/$courseId/stop_pause";

// Parrainage (Referral) URLs
String get getUncollectedBonusesUrl => "$baseUrl/conducteur/parrainage/non-rembourses";
String collectBonusUrl(int parrainageId) =>
    "$baseUrl/conducteur/parrainage/remboursement/$parrainageId";

Map<String, String> headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json'
};
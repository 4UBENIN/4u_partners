import 'package:flutter_dotenv/flutter_dotenv.dart';

String get baseUrl => dotenv.env['API_ENDPOINT']!;
String get registerUrl => "$baseUrl/partenaire/register";
String get loginUrl => "$baseUrl/partenaire/login";
String get coursesPendingUrl => "$baseUrl/conducteur/courses";
String acceptCourseUrl(int courseId) =>
    "$baseUrl/conducteur/courses/$courseId/accept";
String rejectCourseUrl(int courseId) =>
    "$baseUrl/conducteur/courses/$courseId/deny";
String startCourseUrl(int courseId) =>
    "$baseUrl/conducteur/courses/$courseId/start";
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
Map<String, String> headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json'
};
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ✅ Avec gestion d'erreur claire
String get baseUrl {
  final url = dotenv.env['API_ENDPOINT'];
  if (url == null || url.isEmpty) {
    throw Exception(
      '❌ API_ENDPOINT non configurée!\n'
      'Vérifiez que:\n'
      '1. Le fichier .env existe à la racine du projet\n'
      '2. Il contient: API_ENDPOINT=https://votre-api.com/api\n'
      '3. Le fichier .env est dans pubspec.yaml sous assets'
    );
  }
  return url;
}

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
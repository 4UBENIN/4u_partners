import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstant {
  static String baseUrl = dotenv.env['API_ENDPOINT']!;
  static String mapboxUrl = dotenv.env['MAPBOX_URL']!;
  static String mapboxprivaToken = dotenv.env['MAPBOX_PRIVATE_TOKEN']!;
  static String get saveFcmTokenDriver => '$baseUrl/conducteur/save-fcm-token';
  static String get saveFcmTokenPressing => '$baseUrl/pressing/save-fcm-token';
  static String get saveDriverPosition => '$baseUrl/conducteur/position';
  static String get getDriverNotifications => '$baseUrl/conducteur/notifications';
  static String markNotificationAsRead(int id) => '$baseUrl/conducteur/notifications/$id/read';
}

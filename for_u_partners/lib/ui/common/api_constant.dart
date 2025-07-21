import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstant {
  static String baseUrl = dotenv.env['AUTH_ENDPOINT']!;
  static String mapboxUrl = dotenv.env['MAPBOX_URL']!;
  static String mapboxprivaToken = dotenv.env['MAPBOX_PRIVATE_TOKEN']!;
}

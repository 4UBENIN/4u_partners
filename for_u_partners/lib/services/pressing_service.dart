import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:for_u_partners/app/api_constant.dart';
import 'package:for_u_partners/app/models/pressing_dashboard_model.dart';
// import 'package:for_u_partners/app/app.locator.dart';
// import 'package:stacked_services/stacked_services.dart';
// import 'package:for_u_partners/services/sharedpreferences_service.dart';

class PressingService {
  // final _sharedPreferencesServices = locator<SharedpreferencesService>();
  // final _navigationService = locator<NavigationService>();

  //* GET PRESSING INFO
  Future<PressingResponse?> getPressingInfo() async {
    final url =
        Uri.parse("https://foryou.cilassocies.com/api/pressing/dashboard");

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return PressingResponse.fromJson(jsonData);
      } else {
        print("Erreur : ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Erreur lors de la récupération des infos pressing : $e");
      return null;
    }
  }
}

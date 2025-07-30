import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/app/api_constant.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/app/models/login_model.dart';
import 'package:for_u_partners/app/models/register_model.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';

class AuthService {
  final _sharedPreferencesServices = locator<SharedpreferencesService>();
  final _navigationService = locator<NavigationService>();

  Future<void> login(LoginModel loginModel) async {
    final url = Uri.parse(loginUrl);
    final response =
        await http.post(url, headers: headers, body: loginModel.toJson());

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);

      final loginResponse = LoginResponseModel.fromJson(responseJson);
      _sharedPreferencesServices.saveToken(loginResponse.token);
      switch (loginResponse.user.role) {
        case 'livreur':
          _navigationService.replaceWithDeliveryNavBarView();
          break;
        case 'conducteur':
          _navigationService.replaceWithHomemainView();
          break;
        case 'coursier':
          _navigationService.replaceWithDeliveryNavBarView();
          break;
        case 'pressing':
          _navigationService.replaceWithNavBarPressingView();
          break;
        default:
          _navigationService.replaceWithNavBarPressingView();
      }
    }
  }

  Future<void> register(RegistrationModel registrationModel) async {
    final url = Uri.parse(registerUrl);
    final response = await http.post(url,
        headers: headers, body: registrationModel.toJson());

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
    }
  }
}

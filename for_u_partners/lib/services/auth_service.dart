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

  //* LOGIN FUNCTION

  Future<void> login(LoginModel loginModel, String type) async {
    final url =
        Uri.parse("https://foryou.cilassocies.com/api/partenaire/login");

    final response = await http.post(url,
        headers: headers, body: jsonEncode(loginModel.toJson()));

    print("type");
    print(type);

    print("status");
    print(response.statusCode);

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      print("reponseJson");
      print(responseJson);

      final loginResponse = LoginPressingResponseModel.fromJson(responseJson);
      await _sharedPreferencesServices.saveToken(loginResponse.token);

      print("login response");
      print(loginResponse);

      switch (type) {
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
          print("Dans pressing ici");
          _navigationService.replaceWithNavBarPressingView();
          break;
        default:
          _navigationService.replaceWithNavBarPressingView();
      }
    } else {
      throw Exception('Something went wrong');
    }
  }

  //* REGISTER FUNCTION

  Future<void> register(RegistrationModel registrationModel) async {
    final url =
        Uri.parse("https://foryou.cilassocies.com/api/partenaire/register");
    print(url);
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(registrationModel.toJson()),
      );

      print(
          registrationModel.toJson()); // <- ce print doit maintenant s'afficher

      if (response.statusCode == 201) {
        final responseJson = jsonDecode(response.body);
        final registerType = responseJson['type'];

        await _sharedPreferencesServices.saveToken(responseJson['token']);
        await _sharedPreferencesServices.saveUserId(responseJson['data']['id']);
        await _sharedPreferencesServices.saveUserType(registerType);

        switch (registerType) {
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
      } else {
        print('Erreur statusCode : ${response.statusCode}');
        print('Body : ${response.body}');
      }
    } catch (e, stack) {
      print('Erreur pendant l\'envoi de la requête : $e');
      print('Stack trace : $stack');
    }
  }
}

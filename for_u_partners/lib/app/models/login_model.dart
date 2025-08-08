import 'package:for_u_partners/app/models/pressing_model.dart';
import 'package:for_u_partners/app/models/user_model.dart';

class LoginModel {
  String? type;
  String? telephone;
  String? motDePasse;

  LoginModel({this.type, this.telephone, this.motDePasse});

  LoginModel.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    telephone = json['telephone'];
    motDePasse = json['mot_de_passe'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['telephone'] = telephone;
    data['mot_de_passe'] = motDePasse;
    return data;
  }
}

class LoginResponseModel {
  final UserModel user;
  final String token;
  final String message;

  LoginResponseModel({
    required this.user,
    required this.token,
    required this.message,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      user: UserModel.fromJson(json['data']),
      token: json['token'],
      message: json['message'],
    );
  }
}

class LoginPressingResponseModel {
  final Pressing pressing;
  final String token;
  final String message;

  LoginPressingResponseModel({
    required this.pressing,
    required this.token,
    required this.message,
  });

  factory LoginPressingResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginPressingResponseModel(
      pressing: Pressing.fromJson(json['data']),
      token: json['token'],
      message: json['message'],
    );
  }
}

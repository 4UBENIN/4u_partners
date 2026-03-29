import 'package:flutter/material.dart';
import 'package:for_u_partners/app/models/login_model.dart';
import 'package:for_u_partners/app/validators/form_validators.dart';
import 'package:for_u_partners/services/auth_service.dart';
import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';

class LoginViewModel extends FormViewModel {
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();
  
  // État du formulaire
  bool obscurePassword = true;
  bool _isFormValid = false;
  bool _isPhoneNumberTouched = false;
  bool _isProfileTouched = false;
  bool _isPasswordTouched = false;
  
  // Messages d'erreur
  String? _phoneNumberError;
  String? _profileError;
  String? _loginError;
  String? _passwordError;
  
  // Liste des profils disponibles
  final List<String> profiles = [
    "pressing",
    "livreur",
    "conducteur",
    "agent d'entretien",
    "garagiste"
  ];

  // Getters pour les erreurs
  String? get loginError => _loginError;
  String? get phoneNumberErrorText => _isPhoneNumberTouched ? _phoneNumberError : null;
  String? get profileErrorText => _isProfileTouched && _profileError != null ? _profileError : null;
  String? get passwordErrorText => _isPasswordTouched ? _passwordError : null;
  bool get isFormValid => _isFormValid;

  String _selectedProfile = "pressing";
  String get selectedProfile => _selectedProfile;

  //* VALIDATION DU FORMULAIRE
  
  bool validateForm(String phoneNumber, String password) {
    _isPhoneNumberTouched = true;
    _isProfileTouched = true;
    _isPasswordTouched = true;
    
    // Validation du numéro de téléphone
    _phoneNumberError = PhoneValidators.validatePhoneNumber(phoneNumber);
    
    // Validation du mot de passe
    _passwordError = password.isEmpty ? 'Le mot de passe est requis' : null;
    
    // Validation du profil
    _profileError = _selectedProfile.isEmpty ? 'Veuillez sélectionner un profil' : null;
    
    // Mise à jour de l'état de validité du formulaire
    _updateFormValidity();
    
    return _isFormValid;
  }

  //* GESTION DES CHAMPS
  
  void onPhoneNumberChanged(String value) {
    _isPhoneNumberTouched = true;
    _phoneNumberError = PhoneValidators.validatePhoneNumber(value);
    _updateFormValidity();
    rebuildUi();
  }
  
  void setSelectedProfile(String value) {
    _isProfileTouched = true;
    _selectedProfile = value;
    _profileError = value.isEmpty ? 'Veuillez sélectionner un profil' : null;
    _updateFormValidity();
    rebuildUi();
  }
  
  void onPasswordFieldTouched() {
    _isPasswordTouched = true;
    _updateFormValidity();
    rebuildUi();
  }
  
  void _updateFormValidity() {
    _isFormValid = _phoneNumberError == null &&
        _profileError == null &&
        _passwordError == null &&
        _isPhoneNumberTouched &&
        _isProfileTouched &&
        _isPasswordTouched;
  }

  //* ACTIONS
  
  Future<void> login(LoginModel model, BuildContext context) async {
    setBusy(true);
    _loginError = null;
    rebuildUi();
    
    try {
      await _authService.login(model, context);
    } on String catch (error) {
      _loginError = error;
      rebuildUi();
    } catch (e) {
      _loginError = 'Une erreur est survenue lors de la connexion';
      rebuildUi();
    } finally {
      setBusy(false);
    }
  }

  void register() {
    _navigationService.replaceWithRegisterView();
  }

  void viewPassword() {
    obscurePassword = !obscurePassword;
    rebuildUi();
  }
  
}

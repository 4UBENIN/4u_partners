import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/views/auth/register/register_view.form.dart';
import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/app/validators/form_validators.dart';

class RegisterViewModel extends FormViewModel {
  final navigationService = locator<NavigationService>();

  final profiles = [
    "pressing",
    "livreur",
    "conducteur",
    "agent d'entretien",
    "garagiste"
  ];

  bool obscurePassword = true;
  bool hasPasswordBeenTouched = false;
  bool _isPhoneNumberTouched = false;
  bool _isEmailTouched = false;
  bool _isProfileTouched = false;
  String? _registrationError;
  String? get registrationError => _registrationError;

  String _selectedProfile = "pressing";
  String get selectedProfile => _selectedProfile;
  
  bool get isFormValid =>
      phoneNumberInputValidationMessage == null &&
      emailInputValidationMessage == null &&
      passwordInputValidationMessage == null &&
      _selectedProfile.isNotEmpty &&
      _isPhoneNumberTouched &&
      _isEmailTouched &&
      _isProfileTouched;
      
  String? get profileErrorText {
    if (!_isProfileTouched) return null;
    return _selectedProfile.isEmpty ? 'Veuillez sélectionner un profil' : null;
  }

  //* FONCTIONS

  void viewPassword() {
    obscurePassword = !obscurePassword;
    rebuildUi();
  }

  void login() {
    navigationService.replaceWithLoginView();
  }

  void setSelectedProfile(String value) {
    _selectedProfile = value;
    _isProfileTouched = true;
    rebuildUi();
  }
  
  void onPhoneNumberChanged() {
    _isPhoneNumberTouched = true;
    rebuildUi();
  }
  
  void onEmailChanged() {
    _isEmailTouched = true;
    rebuildUi();
  }

  // Nouvelle méthode pour marquer que le champ password a été touché
  void onPasswordFieldTouched() {
    if (!hasPasswordBeenTouched) {
      hasPasswordBeenTouched = true;
      rebuildUi();
    }
  }

  // Méthode pour obtenir le message d'erreur seulement si le champ a été touché
  String? get passwordErrorText {
    if (!hasPasswordBeenTouched) {
      return null; // Ne pas afficher d'erreur si pas encore touché
    }
    return passwordInputValidationMessage;
  }
  
  // Évalue la force du mot de passe
  Map<String, dynamic> evaluatePasswordStrength(String password) {
    int strength = 0;
    String message = 'Faible';
    Color color = Colors.red;
    
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) strength++;
    
    if (strength > 3) {
      message = 'Fort';
      color = Colors.green;
    } else if (strength > 1) {
      message = 'Moyen';
      color = Colors.orange;
    }
    
    return {
      'strength': strength / 4, // Normalisé entre 0 et 1
      'message': 'Sécurité du mot de passe: $message',
      'color': color,
    };
  }

  bool validateForm(String phoneNumber, String email, String password) {
    _isPhoneNumberTouched = true;
    _isEmailTouched = true;
    _isProfileTouched = true;
    hasPasswordBeenTouched = true;
    
    final phoneValid = PhoneValidators.validatePhoneNumber(phoneNumber) == null;
    final emailValid = EmailValidators.validateEmail(email) == null;
    final passwordValid = PasswordValidators.validatePassword(password) == null;
    final profileValid = _selectedProfile.isNotEmpty;
    
    rebuildUi();
    
    return phoneValid && emailValid && passwordValid && profileValid;
  }
  
  Future<bool> registerByProfile() async {
    // Cette méthode est appelée lors de la soumission du formulaire
    // Elle vérifie si le numéro est déjà utilisé
    try {
      // Simulation d'une vérification du numéro
      // En production, ce serait un appel API
      await Future.delayed(const Duration(seconds: 1));
      
      // Vérification si le numéro est déjà utilisé
      if (phoneNumberInputValue == '0123456789') {
        _registrationError = 'Ce numéro de téléphone est déjà utilisé';
        rebuildUi();
        return false;
      }
      
      // Si tout est bon, on réinitialise les erreurs
      _registrationError = null;
      rebuildUi();
      return true;
      
    } catch (e) {
      _registrationError = 'Une erreur est survenue lors de l\'inscription';
      rebuildUi();
      return false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/views/auth/register/register_view.form.dart';
import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';

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
  bool _isPhoneNumberTouched = false;
  bool _isEmailTouched = false;
  bool _isPasswordTouched = false;
  bool _isProfileTouched = false;
  
  String? _phoneNumberError;
  String? _emailError;
  String? _passwordError;
  String? _profileError;
  String? _registrationError;

  String _selectedProfile = "pressing";
  String get selectedProfile => _selectedProfile;
  String? get registrationError => _registrationError;

  // Getters pour les erreurs - N'affiche que si le champ a été touché
  String? get phoneNumberErrorText => _isPhoneNumberTouched ? _phoneNumberError : null;
  String? get emailErrorText => _isEmailTouched ? _emailError : null;
  String? get passwordErrorText => _isPasswordTouched ? _passwordError : null;
  String? get profileErrorText => _isProfileTouched ? _profileError : null;
  
  bool get isFormValid =>
      _phoneNumberError == null &&
      _emailError == null &&
      _passwordError == null &&
      _profileError == null &&
      _isPhoneNumberTouched &&
      _isEmailTouched &&
      _isPasswordTouched &&
      _isProfileTouched;

  //* VALIDATION DU NUMÉRO DE TÉLÉPHONE
  String? _validatePhoneNumber(String phoneNumber) {
    final cleanPhone = phoneNumber.trim();
    
    if (cleanPhone.isEmpty) {
      return '📱 Veuillez entrer votre numéro de téléphone';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanPhone)) {
      return '❌ Le numéro doit contenir uniquement des chiffres';
    }
    
    if (cleanPhone.length != 10) {
      return '📏 Le numéro doit contenir exactement 10 chiffres';
    }
    
    if (!cleanPhone.startsWith('01')) {
      return '⚠️ Le numéro doit commencer par 01';
    }
    
    return null;
  }

  //* VALIDATION DE L'EMAIL
  String? _validateEmail(String email) {
    final cleanEmail = email.trim();
    
    if (cleanEmail.isEmpty) {
      return '📧 Veuillez entrer votre adresse email';
    }
    
    // Regex pour valider l'email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(cleanEmail)) {
      return '❌ Format d\'email invalide. Ex: exemple@mail.com';
    }
    
    // Vérifier les domaines courants
    final domain = cleanEmail.split('@').last.toLowerCase();
    final commonDomains = ['gmail.com', 'yahoo.com', 'outlook.com', 'hotmail.com'];
    
    if (!commonDomains.any((d) => domain == d) && !domain.contains('.')) {
      return '⚠️ Vérifiez votre adresse email';
    }
    
    return null;
  }

  //* VALIDATION DU MOT DE PASSE
  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return '🔒 Veuillez entrer un mot de passe';
    }
    
    if (password.length < 8) {
      return '🔒 Le mot de passe doit contenir au moins 8 caractères';
    }
    
    // Vérifier la présence de différents types de caractères
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    
    if (!hasUppercase) {
      return '🔠 Le mot de passe doit contenir au moins une majuscule';
    }
    
    if (!hasLowercase) {
      return '🔡 Le mot de passe doit contenir au moins une minuscule';
    }
    
    if (!hasDigit) {
      return '🔢 Le mot de passe doit contenir au moins un chiffre';
    }
    
    return null;
  }

  //* VALIDATION DU PROFIL
  String? _validateProfile(String profile) {
    if (profile.isEmpty) {
      return '👤 Veuillez sélectionner votre profil';
    }
    
    if (!profiles.contains(profile)) {
      return '❌ Profil non valide';
    }
    
    return null;
  }

  //* ÉVALUATION DE LA FORCE DU MOT DE PASSE
  Map<String, dynamic> evaluatePasswordStrength(String password) {
    int strength = 0;
    String message = 'Très faible';
    Color color = Colors.red;
    
    // Critères de force
    if (password.length >= 6) strength++;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) strength++;
    
    // Déterminer le niveau de sécurité
    if (strength >= 5) {
      message = '🛡️ Excellent';
      color = Colors.green.shade700;
    } else if (strength >= 4) {
      message = '💪 Fort';
      color = Colors.green;
    } else if (strength >= 3) {
      message = '👍 Moyen';
      color = Colors.orange;
    } else if (strength >= 2) {
      message = '⚠️ Faible';
      color = Colors.orange.shade700;
    } else {
      message = '❌ Très faible';
      color = Colors.red;
    }
    
    return {
      'strength': strength / 6, // Normalisé entre 0 et 1
      'message': message,
      'color': color,
    };
  }

  //* GESTION DES CHANGEMENTS DE CHAMPS
  void onPhoneNumberChanged(String value) {
    _isPhoneNumberTouched = true;
    _phoneNumberError = _validatePhoneNumber(value);
    
    // Réinitialiser l'erreur d'inscription
    if (_registrationError != null) {
      _registrationError = null;
    }
    
    rebuildUi();
  }
  
  void onEmailChanged(String value) {
    _isEmailTouched = true;
    _emailError = _validateEmail(value);
    
    // Réinitialiser l'erreur d'inscription
    if (_registrationError != null) {
      _registrationError = null;
    }
    
    rebuildUi();
  }

  void onPasswordChanged(String value) {
    _isPasswordTouched = true;
    _passwordError = _validatePassword(value);
    
    // Réinitialiser l'erreur d'inscription
    if (_registrationError != null) {
      _registrationError = null;
    }
    
    rebuildUi();
  }

  void onPasswordFieldTouched() {
    _isPasswordTouched = true;
    rebuildUi();
  }

  void setSelectedProfile(String value) {
    _isProfileTouched = true;
    _selectedProfile = value;
    _profileError = _validateProfile(value);
    
    // Réinitialiser l'erreur d'inscription
    if (_registrationError != null) {
      _registrationError = null;
    }
    
    rebuildUi();
  }

  //* VALIDATION COMPLÈTE DU FORMULAIRE
  bool validateForm(String phoneNumber, String email, String password) {
    // Marquer tous les champs comme touchés
    _isPhoneNumberTouched = true;
    _isEmailTouched = true;
    _isPasswordTouched = true;
    _isProfileTouched = true;
    
    // Réinitialiser l'erreur d'inscription
    _registrationError = null;
    
    // Valider tous les champs
    _phoneNumberError = _validatePhoneNumber(phoneNumber);
    _emailError = _validateEmail(email);
    _passwordError = _validatePassword(password);
    _profileError = _validateProfile(_selectedProfile);
    
    rebuildUi();
    
    return _phoneNumberError == null &&
           _emailError == null &&
           _passwordError == null &&
           _profileError == null;
  }

  //* GESTION DES ERREURS D'INSCRIPTION
  String _formatRegistrationError(dynamic error) {
    if (error == null) return '⚠️ Une erreur est survenue lors de l\'inscription';
    
    final errorString = error.toString().toLowerCase();
    
    // Erreurs liées au numéro de téléphone
    if (errorString.contains('téléphone') && errorString.contains('utilisé')) {
      return '📱 Ce numéro de téléphone est déjà utilisé.\nVeuillez vous connecter ou utiliser un autre numéro.';
    }
    
    if (errorString.contains('téléphone') && errorString.contains('invalide')) {
      return '📱 Le numéro de téléphone est invalide.\nVérifiez et réessayez.';
    }
    
    // Erreurs liées à l'email
    if (errorString.contains('email') && errorString.contains('utilisé')) {
      return '📧 Cet email est déjà utilisé.\nVeuillez vous connecter ou utiliser un autre email.';
    }
    
    if (errorString.contains('email') && errorString.contains('invalide')) {
      return '📧 L\'adresse email est invalide.\nVérifiez et réessayez.';
    }
    
    // Erreurs réseau
    if (errorString.contains('réseau') || 
        errorString.contains('network') ||
        errorString.contains('connexion')) {
      return '📡 Problème de connexion internet.\nVérifiez votre connexion et réessayez.';
    }
    
    // Erreurs serveur
    if (errorString.contains('serveur') || 
        errorString.contains('server') ||
        errorString.contains('500')) {
      return '🔧 Problème de connexion au serveur.\nVeuillez réessayer dans quelques instants.';
    }
    
    // Timeout
    if (errorString.contains('timeout')) {
      return '⏱️ La connexion a pris trop de temps.\nVeuillez réessayer.';
    }
    
    // Données manquantes ou invalides
    if (errorString.contains('requis') || errorString.contains('obligatoire')) {
      return '⚠️ Certains champs obligatoires sont manquants.\nVérifiez le formulaire.';
    }
    
    // Message par défaut
    return '⚠️ Une erreur est survenue lors de l\'inscription.\nVeuillez vérifier vos informations et réessayer.';
  }

  //* INSCRIPTION
  Future<bool> registerByProfile() async {
    setBusy(true);
    _registrationError = null;
    rebuildUi();
    
    try {
      // Simulation d'une vérification (à remplacer par votre appel API réel)
      await Future.delayed(const Duration(seconds: 1));
      
      // Exemple de vérification - À remplacer par votre logique réelle
      // if (phoneNumberInputValue == '0123456789') {
      //   throw Exception('Ce numéro de téléphone est déjà utilisé');
      // }
      
      // Si tout est bon
      _registrationError = null;
      rebuildUi();
      return true;
      
    } catch (e) {
      // Formater l'erreur de manière conviviale
      _registrationError = _formatRegistrationError(e);
      rebuildUi();
      return false;
    } finally {
      setBusy(false);
    }
  }

  //* AUTRES ACTIONS
  void viewPassword() {
    obscurePassword = !obscurePassword;
    rebuildUi();
  }

  void login() {
    navigationService.replaceWithLoginView();
  }

  //* RÉINITIALISER LE FORMULAIRE
  void resetForm() {
    _isPhoneNumberTouched = false;
    _isEmailTouched = false;
    _isPasswordTouched = false;
    _isProfileTouched = false;
    _phoneNumberError = null;
    _emailError = null;
    _passwordError = null;
    _profileError = null;
    _registrationError = null;
    _selectedProfile = "pressing";
    obscurePassword = true;
    rebuildUi();
  }
}
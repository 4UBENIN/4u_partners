import 'package:flutter/material.dart';
import 'package:for_u_partners/app/models/login_model.dart';
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
  String? get phoneNumberErrorText =>
      _isPhoneNumberTouched ? _phoneNumberError : null;
  String? get profileErrorText => _isProfileTouched ? _profileError : null;
  String? get passwordErrorText => _isPasswordTouched ? _passwordError : null;
  bool get isFormValid => _isFormValid;

  String _selectedProfile = "pressing";
  String get selectedProfile => _selectedProfile;

  //* ---------------- VALIDATION DU FORMULAIRE ----------------

  String? _validatePhoneNumber(String phoneNumber) {
    final cleanPhone = phoneNumber.trim();

    if (cleanPhone.isEmpty) return '📱 Veuillez entrer votre numéro de téléphone';
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

  String? _validatePassword(String password) {
    if (password.isEmpty) return '🔒 Veuillez entrer votre mot de passe';
    if (password.length < 8) {
      return '🔒 Le mot de passe doit contenir au moins 8 caractères';
    }
    return null;
  }

  String? _validateProfile(String profile) {
    if (profile.isEmpty) return '👤 Veuillez sélectionner votre profil';
    if (!profiles.contains(profile)) return '❌ Profil non valide';
    return null;
  }

  bool validateForm(String phoneNumber, String password) {
    _isPhoneNumberTouched = true;
    _isProfileTouched = true;
    _isPasswordTouched = true;
    _loginError = null;

    _phoneNumberError = _validatePhoneNumber(phoneNumber);
    _passwordError = _validatePassword(password);
    _profileError = _validateProfile(_selectedProfile);

    _updateFormValidity();
    rebuildUi();
    return _isFormValid;
  }

  void _updateFormValidity() {
    _isFormValid = _phoneNumberError == null &&
        _profileError == null &&
        _passwordError == null;
  }

  //* ---------------- CHANGEMENTS DES CHAMPS ----------------

  void onPhoneNumberChanged(String value) {
    _isPhoneNumberTouched = true;
    _phoneNumberError = _validatePhoneNumber(value);
    _loginError = null;
    _updateFormValidity();
    rebuildUi();
  }

  void setSelectedProfile(String value) {
    _isProfileTouched = true;
    _selectedProfile = value;
    _profileError = _validateProfile(value);
    _loginError = null;
    _updateFormValidity();
    rebuildUi();
  }

  void onPasswordFieldTouched() {
    _isPasswordTouched = true;
    rebuildUi();
  }

  void onPasswordChanged(String value) {
    _isPasswordTouched = true;
    _passwordError = _validatePassword(value);
    _loginError = null;
    _updateFormValidity();
    rebuildUi();
  }

  //* ---------------- FORMATAGE DES ERREURS ----------------

  String _formatLoginError(String error) {
    final errorLower = error.toLowerCase();

    // Si le message vient directement de ton API (ex: "Ce numéro n’est pas enregistré pour ce type de partenaire")
    if (error.contains("Ce numéro") ||
        error.contains("Mot de passe") ||
        error.contains("non enregistré") ||
        error.contains("type de partenaire")) {
      return error;
    }

    // Cas classiques
    if (errorLower.contains('incorrect') ||
        errorLower.contains('invalide') ||
        errorLower.contains('wrong')) {
      return '❌ Numéro ou mot de passe incorrect.\nVeuillez vérifier et réessayer.';
    }

    if (errorLower.contains('not found') || errorLower.contains('introuvable')) {
      return '👤 Aucun compte trouvé avec ce numéro.\nVeuillez créer un compte.';
    }

    if (errorLower.contains('unauthenticated')) {
      return '🔒 Session expirée ou accès refusé.\nVeuillez vous reconnecter.';
    }

    if (errorLower.contains('réseau') ||
        errorLower.contains('network') ||
        errorLower.contains('connexion')) {
      return '📡 Problème de connexion Internet.\nVérifiez votre connexion et réessayez.';
    }

    if (errorLower.contains('timeout')) {
      return '⏱️ Le serveur met trop de temps à répondre.\nVeuillez réessayer.';
    }

    if (errorLower.contains('500') ||
        errorLower.contains('serveur') ||
        errorLower.contains('server')) {
      return '🔧 Erreur interne du serveur.\nVeuillez réessayer plus tard.';
    }

    // Message générique par défaut
    return '⚠️ Une erreur est survenue lors de la connexion.\nVeuillez réessayer.';
  }

  //* ---------------- CONNEXION ----------------

  Future<void> login(LoginModel model, BuildContext context) async {
    print("🔵 [LoginViewModel] Début de la méthode login()");
    print("🔵 [LoginViewModel] Téléphone: ${model.telephone}");
    print("🔵 [LoginViewModel] Type: ${model.type}");

    setBusy(true);
    print("🔵 [LoginViewModel] setBusy(true) - Loading démarré");
    _loginError = null;
    rebuildUi();

    try {
      print("🔵 [LoginViewModel] Appel de _authService.login()...");
      await _authService.login(model, context);
      print("🟢 [LoginViewModel] _authService.login() terminé avec succès");
      // Si la connexion réussit, la navigation se fait dans le service
    } on String catch (error) {
      // Erreur connue renvoyée par le service
      print("⚠️ [LoginViewModel] Erreur renvoyée par AuthService: $error");
      _loginError = _formatLoginError(error);
      rebuildUi();
    } catch (e) {
      // Erreur inattendue
      print("❌ [LoginViewModel] Erreur inattendue: $e");
      print("❌ [LoginViewModel] Type d'erreur: ${e.runtimeType}");
      _loginError =
          '⚠️ Une erreur inattendue est survenue.\nVeuillez réessayer.';
      rebuildUi();
    } finally {
      print("🔵 [LoginViewModel] Finally - setBusy(false)");
      setBusy(false);
      print("🔵 [LoginViewModel] Loading arrêté");
    }
  }

  //* ---------------- AUTRES ACTIONS ----------------

  void register() {
    _navigationService.replaceWithRegisterView();
  }

  void viewPassword() {
    obscurePassword = !obscurePassword;
    rebuildUi();
  }

  void resetForm() {
    _isPhoneNumberTouched = false;
    _isProfileTouched = false;
    _isPasswordTouched = false;
    _phoneNumberError = null;
    _profileError = null;
    _passwordError = null;
    _loginError = null;
    _isFormValid = false;
    _selectedProfile = "pressing";
    obscurePassword = true;
    rebuildUi();
  }
}

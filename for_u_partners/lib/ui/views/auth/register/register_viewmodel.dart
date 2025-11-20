import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/ui/views/otp/otp_view.dart';
import 'package:for_u_partners/services/auth_service.dart';
import 'register_view.form.dart';

class RegisterViewModel extends FormViewModel with $RegisterView {
  final navigationService = locator<NavigationService>();
  final _authService = locator<AuthService>();

  final profiles = [
    "pressing",
    "livreur",
    "conducteur",
    "agent d'entretien",
    "garagiste"
  ];

  // GESTION DES ÉTAPES
  int _currentStep = 0;
  int get currentStep => _currentStep;
  int get totalSteps => 4;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  // États de validation
  String? _phoneNumberError;
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _addressError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _profileError;
  String? _registrationError;

  String _selectedProfile = "pressing";
  String get selectedProfile => _selectedProfile;
  String? get registrationError => _registrationError;

  // Getters pour les erreurs
  String? get phoneNumberErrorText => _phoneNumberError;
  String? get firstNameErrorText => _firstNameError;
  String? get lastNameErrorText => _lastNameError;
  String? get emailErrorText => _emailError;
  String? get addressErrorText => _addressError;
  String? get passwordErrorText => _passwordError;
  String? get confirmPasswordErrorText => _confirmPasswordError;
  String? get profileErrorText => _profileError;

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

  String? _validateFirstName(String firstName) {
    final cleanFirstName = firstName.trim();

    if (cleanFirstName.isEmpty) {
      return '👤 Veuillez entrer votre prénom';
    }

    if (cleanFirstName.length < 2) {
      return '⚠️ Le prénom doit contenir au moins 2 caractères';
    }

    return null;
  }

  String? _validateLastName(String lastName) {
    final cleanLastName = lastName.trim();

    if (cleanLastName.isEmpty) {
      return '👤 Veuillez entrer votre nom';
    }

    if (cleanLastName.length < 2) {
      return '⚠️ Le nom doit contenir au moins 2 caractères';
    }

    return null;
  }

  String? _validateEmail(String email) {
    final cleanEmail = email.trim();

    if (cleanEmail.isEmpty) {
      return '📧 Veuillez entrer votre adresse email';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(cleanEmail)) {
      return '❌ Format d\'email invalide';
    }

    return null;
  }

  String? _validateAddress(String address) {
    final cleanAddress = address.trim();

    if (cleanAddress.isEmpty) {
      return '📍 Veuillez entrer votre adresse';
    }

    if (cleanAddress.length < 5) {
      return '⚠️ L\'adresse doit contenir au moins 5 caractères';
    }

    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return '🔒 Veuillez entrer un mot de passe';
    }

    if (password.length < 8) {
      return '🔒 Le mot de passe doit contenir au moins 8 caractères';
    }

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

  String? _validateConfirmPassword(String confirmPassword, String password) {
    if (confirmPassword.isEmpty) {
      return '🔒 Veuillez confirmer votre mot de passe';
    }

    if (confirmPassword != password) {
      return '❌ Les mots de passe ne correspondent pas';
    }

    return null;
  }

  String? _validateProfile(String profile) {
    if (profile.isEmpty) {
      return '👤 Veuillez sélectionner votre profil';
    }

    if (!profiles.contains(profile)) {
      return '❌ Profil non valide';
    }

    return null;
  }

  void onPhoneNumberChanged(String value) {
    _phoneNumberError = _validatePhoneNumber(value);
    rebuildUi();
  }

  void onFirstNameChanged(String value) {
    _firstNameError = _validateFirstName(value);
    rebuildUi();
  }

  void onLastNameChanged(String value) {
    _lastNameError = _validateLastName(value);
    rebuildUi();
  }

  void onEmailChanged(String value) {
    _emailError = _validateEmail(value);
    rebuildUi();
  }

  void onAddressChanged(String value) {
    _addressError = _validateAddress(value);
    rebuildUi();
  }

  void onPasswordChanged(String value) {
    _passwordError = _validatePassword(value);
    rebuildUi();
  }

  void onConfirmPasswordChanged(String value, String password) {
    _confirmPasswordError = _validateConfirmPassword(value, password);
    rebuildUi();
  }

  void setSelectedProfile(String value) {
    _selectedProfile = value;
    _profileError = _validateProfile(value);
    rebuildUi();
  }

  bool _validateStep1(String phoneNumber, String firstName, String lastName) {
    _phoneNumberError = _validatePhoneNumber(phoneNumber);
    _firstNameError = _validateFirstName(firstName);
    _lastNameError = _validateLastName(lastName);
    rebuildUi();

    return _phoneNumberError == null &&
        _firstNameError == null &&
        _lastNameError == null;
  }

  bool _validateStep2(String email, String address) {
    _emailError = _validateEmail(email);
    _addressError = _validateAddress(address);
    rebuildUi();

    return _emailError == null && _addressError == null;
  }

  bool _validateStep3(String password, String confirmPassword) {
    _passwordError = _validatePassword(password);
    _confirmPasswordError = _validateConfirmPassword(confirmPassword, password);
    rebuildUi();

    return _passwordError == null && _confirmPasswordError == null;
  }

  bool _validateStep4() {
    _profileError = _validateProfile(_selectedProfile);
    rebuildUi();

    return _profileError == null;
  }

  bool validateCurrentStep({
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? email,
    String? address,
    String? password,
    String? confirmPassword,
  }) {
    switch (_currentStep) {
      case 0:
        return _validateStep1(
          phoneNumber ?? '',
          firstName ?? '',
          lastName ?? '',
        );
      case 1:
        return _validateStep2(
          email ?? '',
          address ?? '',
        );
      case 2:
        return _validateStep3(
          password ?? '',
          confirmPassword ?? '',
        );
      case 3:
        return _validateStep4();
      default:
        return false;
    }
  }

  bool canGoToNextStep({
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? email,
    String? address,
    String? password,
    String? confirmPassword,
  }) {
    switch (_currentStep) {
      case 0:
        return phoneNumber != null &&
            firstName != null &&
            lastName != null &&
            _validatePhoneNumber(phoneNumber) == null &&
            _validateFirstName(firstName) == null &&
            _validateLastName(lastName) == null;

      case 1:
        return email != null &&
            address != null &&
            _validateEmail(email) == null &&
            _validateAddress(address) == null;

      case 2:
        return password != null &&
            confirmPassword != null &&
            _validatePassword(password) == null &&
            _validateConfirmPassword(confirmPassword, password) == null;

      case 3:
        return _validateProfile(_selectedProfile) == null;

      default:
        return false;
    }
  }

  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      _registrationError = null;
      rebuildUi();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      _registrationError = null;
      rebuildUi();
    }
  }

  Map<String, dynamic> evaluatePasswordStrength(String password) {
    int strength = 0;
    String message = 'Très faible';
    Color color = Colors.red;

    if (password.length >= 6) strength++;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) strength++;

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
    }

    return {
      'strength': strength / 6,
      'message': message,
      'color': color,
    };
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    rebuildUi();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    rebuildUi();
  }

  String _formatRegistrationError(dynamic error) {
    if (error == null) {
      return '⚠️ Une erreur est survenue lors de l\'inscription';
    }

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('téléphone') && errorString.contains('utilisé')) {
      return '📱 Ce numéro de téléphone est déjà utilisé';
    }

    if (errorString.contains('email') && errorString.contains('utilisé')) {
      return '📧 Cet email est déjà utilisé';
    }

    if (errorString.contains('réseau') || errorString.contains('network')) {
      return '📡 Problème de connexion internet';
    }

    return '⚠️ Une erreur est survenue lors de l\'inscription';
  }

  Future<void> handleOtpNavigation() async {
    final result = await navigationService.navigateToView(
      OtpView(
        phoneNumber: phoneNumberController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        address: addressController.text.trim(),
      ),
    );

    if (result != null && result is Map) {
      if (result['action'] == 'goToProfileStep') {
        _currentStep = 3;
        rebuildUi();
      } else if (result['action'] == 'goToPhoneStep') {
        _currentStep = 0;
        if (result['phoneNumber'] != null) {
          phoneNumberController.text = result['phoneNumber'];
          _phoneNumberError = _validatePhoneNumber(result['phoneNumber']);
        }
        rebuildUi();
      }
    }
  }

  Future<bool> registerByProfile() async {
    print("🟢 [RegisterViewModel] Début registerByProfile()");
    setBusy(true);
    _registrationError = null;
    rebuildUi();

    try {
      final phoneNumber = phoneNumberController.text.trim();
      print("🟢 [RegisterViewModel] Numéro de téléphone: $phoneNumber");

      if (phoneNumber.isEmpty) {
        print("🔴 [RegisterViewModel] Numéro de téléphone vide");
        _registrationError = 'Veuillez entrer un numéro de téléphone valide';
        rebuildUi();
        return false;
      }

      // Envoi du code OTP
      print("🟢 [RegisterViewModel] Appel de sendOtpCode...");
      final result = await _authService.sendOtpCode(phoneNumber);
      print("🟢 [RegisterViewModel] Résultat sendOtpCode: $result");

      if (result['success'] == true) {
        print("✅ [RegisterViewModel] Code OTP envoyé avec succès");
        print("🟢 [RegisterViewModel] Navigation vers OtpView...");
        await handleOtpNavigation();

        _registrationError = null;
        rebuildUi();
        return true;
      } else {
        print("🔴 [RegisterViewModel] Échec de l'envoi du code OTP");
        _registrationError = result['message'] ?? 'Erreur lors de l\'envoi du code';
        rebuildUi();
        return false;
      }
    } catch (e) {
      print("❌ [RegisterViewModel] Exception dans registerByProfile(): $e");
      _registrationError = _formatRegistrationError(e);
      rebuildUi();
      return false;
    } finally {
      setBusy(false);
      print("🟢 [RegisterViewModel] Fin registerByProfile()");
    }
  }

  void login() {
    navigationService.replaceWithLoginView();
  }

  void resetForm() {
    _currentStep = 0;
    _phoneNumberError = null;
    _firstNameError = null;
    _lastNameError = null;
    _emailError = null;
    _addressError = null;
    _passwordError = null;
    _confirmPasswordError = null;
    _profileError = null;
    _registrationError = null;
    _selectedProfile = "pressing";
    obscurePassword = true;
    obscureConfirmPassword = true;
    rebuildUi();
  }
}
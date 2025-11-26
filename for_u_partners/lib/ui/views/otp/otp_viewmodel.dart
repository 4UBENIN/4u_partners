import 'dart:async';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/auth_service.dart';

class OtpViewModel extends BaseViewModel {
  final NavigationService navigationService = locator<NavigationService>();
  final _authService = locator<AuthService>();

  // Propriétés
  final int otpLength = 4; 
  List<String> _otpDigits = [];
  String? _otpError;
  bool _isOtpComplete = false;
  bool _canResend = false;
  int _resendTimer = 30;
  Timer? _timer;
  String _phoneNumber = '';

  // Getters
  List<String> get otpDigits => _otpDigits;
  String? get otpError => _otpError;
  bool get isOtpComplete => _isOtpComplete;
  bool get canResend => _canResend;
  int get resendTimer => _resendTimer;
  String get maskedPhoneNumber {
    return _phoneNumber;
  }
  String get otpCode => _otpDigits.join();
  void initialize(String phoneNumber) {
    _phoneNumber = phoneNumber;
    _otpDigits = List.filled(otpLength, '', growable: false);
    startResendTimer();
  }

  void goBackToProfileSelection() {
    navigationService.back(
      result: {
        'action': 'goToProfileStep',
      },
    );
  }

  void navigateToPhoneNumberEdit() {
    navigationService.back(
      result: {
        'action': 'goToPhoneStep',
        'phoneNumber': _phoneNumber,
      },
    );
  }

  void setOtpDigit(int index, String value) {
    if (index >= 0 && index < _otpDigits.length) {
      _otpDigits[index] = value;
      _checkOtpCompletion();
      notifyListeners();
    }
  }

  void _checkOtpCompletion() {
    final isComplete = _otpDigits.every((digit) => digit.isNotEmpty);
    if (isComplete != _isOtpComplete) {
      _isOtpComplete = isComplete;
      _otpError = null;
    }
  }

  Future<bool> verifyOtp() async {
    print("🟠 [OtpViewModel] Début verifyOtp()");
    if (!_isOtpComplete) {
      print("🔴 [OtpViewModel] OTP incomplet");
      return false;
    }

    setBusy(true);
    _otpError = null;

    try {
      final otpCode = _otpDigits.join();
      print("🟠 [OtpViewModel] Code OTP: $otpCode");
      print("🟠 [OtpViewModel] Numéro de téléphone: $_phoneNumber");

      print("🟠 [OtpViewModel] Appel de verifyOtpCode...");
      final result = await _authService.verifyOtpCode(_phoneNumber, otpCode);
      print("🟠 [OtpViewModel] Résultat verifyOtpCode: $result");

      if (result['success'] == true) {
        print("✅ [OtpViewModel] Code OTP vérifié avec succès");
        return true;
      } else {
        print("🔴 [OtpViewModel] Code OTP invalide");
        _otpError = result['message'] ?? 'Code OTP invalide. Veuillez réessayer.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("❌ [OtpViewModel] Exception dans verifyOtp(): $e");
      _otpError = 'Une erreur est survenue. Veuillez réessayer.';
      notifyListeners();
      return false;
    } finally {
      setBusy(false);
      print("🟠 [OtpViewModel] Fin verifyOtp()");
    }
  }

  Future<void> resendOtp() async {
    print("🟡 [OtpViewModel] Début resendOtp()");
    if (_canResend) {
      setBusy(true);
      _otpError = null;

      try {
        print("🟡 [OtpViewModel] Réinitialisation des champs OTP");
        _otpDigits.fillRange(0, _otpDigits.length, '');
        _isOtpComplete = false;

        print("🟡 [OtpViewModel] Appel de sendOtpCode...");
        final result = await _authService.sendOtpCode(_phoneNumber);
        print("🟡 [OtpViewModel] Résultat sendOtpCode: $result");

        if (result['success'] == true) {
          print("✅ [OtpViewModel] Code OTP renvoyé avec succès");
          startResendTimer();
        } else {
          print("🔴 [OtpViewModel] Échec du renvoi du code OTP");
          _otpError = result['message'] ?? 'Impossible de renvoyer le code. Veuillez réessayer.';
        }
      } catch (e) {
        print("❌ [OtpViewModel] Exception dans resendOtp(): $e");
        _otpError = 'Impossible de renvoyer le code. Veuillez réessayer.';
      } finally {
        setBusy(false);
        notifyListeners();
        print("🟡 [OtpViewModel] Fin resendOtp()");
      }
    } else {
      print("⚠️ [OtpViewModel] Impossible de renvoyer le code - timer non expiré");
    }
  }

  void startResendTimer() {
    _canResend = false;
    _resendTimer = 30;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        _resendTimer--;
        notifyListeners();
      } else {
        _canResend = true;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

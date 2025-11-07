import 'dart:async';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/app/app.locator.dart';

class OtpViewModel extends BaseViewModel {
  final NavigationService navigationService = locator<NavigationService>();

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
    if (!_isOtpComplete) return false;

    setBusy(true);
    _otpError = null;

    try {
      await Future.delayed(const Duration(seconds: 1));

      final otpCode = _otpDigits.join();

      final isValid = await _verifyOtpWithServer(otpCode);

      if (!isValid) {
        _otpError = 'Code OTP invalide. Veuillez réessayer.';
        notifyListeners();
        return false;
      }

      return true;
    } catch (e) {
      _otpError = 'Une erreur est survenue. Veuillez réessayer.';
      notifyListeners();
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<bool> _verifyOtpWithServer(String otpCode) async {
    await Future.delayed(const Duration(seconds: 1));
    return RegExp(r'^\d+$').hasMatch(otpCode);
  }

  Future<void> resendOtp() async {
    if (_canResend) {
      setBusy(true);
      _otpError = null;

      try {
        _otpDigits.fillRange(0, _otpDigits.length, '');
        _isOtpComplete = false;

        await Future.delayed(const Duration(seconds: 1));

        startResendTimer();

        // Afficher un message de succès (optionnel)
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Nouveau code envoyé avec succès')),
        // );
      } catch (e) {
        _otpError = 'Impossible de renvoyer le code. Veuillez réessayer.';
      } finally {
        setBusy(false);
        notifyListeners();
      }
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

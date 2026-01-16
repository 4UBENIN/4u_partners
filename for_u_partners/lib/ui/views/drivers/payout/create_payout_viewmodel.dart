import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/payout_service.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/services/driver_service.dart';
import 'package:for_u_partners/ui/common/toast.dart';

class CreatePayoutViewModel extends BaseViewModel {
  final _payoutService = locator<PayoutService>();
  final _sharedPreferencesService = locator<SharedpreferencesService>();
  final _driverService = locator<DriverService>();
  final _navigationService = locator<NavigationService>();

  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final passwordController = TextEditingController();

  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un montant';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Montant invalide';
    }
    if (amount <= 0) {
      return 'Le montant doit être supérieur à 0';
    }
    if (amount < 500) {
      return 'Le montant minimum est de 500 FCFA';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }
    return null;
  }

  /// Formats phone number to 8 digits by removing country code and prefix
  ///
  /// Examples:
  /// - "+2290196050020" -> "96050020"
  /// - "2290196050020" -> "96050020"
  /// - "22901234567" -> "01234567"
  /// - "96050020" -> "96050020"
  String _formatPhoneNumber(String phone) {
    String cleanPhone = phone.trim();

    // Remove "+" if present
    if (cleanPhone.startsWith('+')) {
      cleanPhone = cleanPhone.substring(1);
    }

    // Remove country code (229) if present
    if (cleanPhone.startsWith('229')) {
      cleanPhone = cleanPhone.substring(3);
    }

    // Remove the '01' prefix if present (old format)
    if (cleanPhone.startsWith('01')) {
      cleanPhone = cleanPhone.substring(2);
    }

    debugPrint('💰 [CreatePayoutViewModel] Phone formatting: $phone -> $cleanPhone');
    return cleanPhone;
  }

  Future<void> createPayout(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final userIdStr = await _sharedPreferencesService.getUserId();
    final userTypeIdStr = await _sharedPreferencesService.getUserTypeId();

    debugPrint('💰 [CreatePayoutViewModel] Retrieved IDs from SharedPreferences:');
    debugPrint('   getUserId(): $userIdStr');
    debugPrint('   getUserTypeId(): $userTypeIdStr');

    if (userIdStr == null) {
      if (context.mounted) {
        CustomToast.showError(context, message: 'Utilisateur non connecté');
      }
      return;
    }

    final userId = int.tryParse(userIdStr);
    if (userId == null) {
      if (context.mounted) {
        CustomToast.showError(context, message: 'ID utilisateur invalide');
      }
      return;
    }

    setBusy(true);
    try {
      final amount = double.parse(amountController.text);
      final password = passwordController.text;

      // Get user profile to retrieve phone number
      debugPrint('💰 [CreatePayoutViewModel] Fetching user profile to get phone number...');
      final user = await _driverService.getUserProfile();
      final formattedPhone = _formatPhoneNumber(user.telephone);

      debugPrint('💰 [CreatePayoutViewModel] Initiating payout creation - User ID: $userId, Amount: $amount FCFA, Phone: $formattedPhone');

      final response = await _payoutService.createPayout(
        utilisateurId: userId,
        password: password,
        amount: amount,
        phone: formattedPhone,
      );

      debugPrint('✅ [CreatePayoutViewModel] Payout request submitted successfully');

      if (context.mounted) {
        CustomToast.showSuccess(context, message: response.message);
      }

      // Clear form
      amountController.clear();
      passwordController.clear();

      // Navigate back to wallet or payout history
      _navigationService.back();

    } catch (e) {
      debugPrint('❌ [CreatePayoutViewModel] Payout creation failed - Error: $e');
      if (context.mounted) {
        CustomToast.showError(context, message: e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      setBusy(false);
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
